class CitizenCard < ActiveRecord::Base
  extend CommonModule

  # business related to data
  before_create :set_num_cards_ground_before_create
  before_update :set_num_cards_ground_before_update

  # relationships
  belongs_to :ground

  # constants for status
  STATUS_AVAILABLE = 'Đang sử dụng'
  STATUS_LOST = 'Bị mất'
  STATUS_LOCK = 'Khóa thẻ'

  STATUS = [ STATUS_AVAILABLE, STATUS_LOST, STATUS_LOCK ].freeze

  # validation
  validates :card_no, presence: { message: "không được để trống" },
                      uniqueness: { case_sensitive: true,
                                    message: "đã đưọc sử dụng" }
  validates :ground_id, presence: { message: "không được để trống" }
  validates :status, presence: { message: "không được để trống" },
                     inclusion: { in: STATUS,
                                  message: "trạng thái không thích hợp" }

  # hash for convert eng to vni
  VNI_COLUMNS = { "card_no" => "mã số thẻ", "ground_id" => "mặt bằng",
                  "status" => "tình trạng" }

  # headers for excel
  HEADERS = ["id", "Mã số thẻ", "Mặt bằng", "Tình trạng"]

  HEADER_COLUMNS = %w(id card_no ground_name status)

  HEADERS_TEMPLATE = ["Mã số thẻ", "Mặt bằng", "Tình trạng" ]

  HEADER_COLUMNS_TEMPLATE = %w(card_no ground_id status)

  # methods
  def ground_name
    if ground.present?
      ground.name
    else
      ''
    end
  end

  def self.search(search)
    if search
      grounds = Ground.all.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      where("ground_id in (:ground_ids) or lower(card_no) like :param",
        { :ground_ids => grounds.map(&:id), :param => "%#{search.downcase}%" })
    else
      all
    end
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    if HEADERS_TEMPLATE != spreadsheet.row(1)
      raise Exception.new("Template không chính xác")
    end
    count = 0
    self.transaction do
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[HEADER_COLUMNS_TEMPLATE, spreadsheet.row(i)].transpose]
        record = new
        record.attributes = row.to_hash.slice(*row.to_hash.keys)
        g = Ground.find_by(:name => row["ground_id"])
        if g.present?
          record.ground_id = g.id
        else
          raise Exception.new("Row thứ #{i} bị lỗi: Mặt bằng không tồn tại")
        end
        if record.save
          count += 1
        else
          raise Exception.new("Row thứ #{i} bị lỗi: #{record.errors.full_messages}")
        end
      end
      raise Exception.new("Không có dữ liệu để thêm thẻ cư dân") if count == 0
    end
    return count
  end

  private
    def set_num_cards_ground_before_create
      if self.ground_id.present?
        ground = Ground.find_by(:id => ground_id)
        ground.update(:num_citizen_cards => (ground.num_citizen_cards + 1))
      end
    end

    def set_num_cards_ground_before_update
      if self.ground_id_changed?
        if self.ground_id_was.present?
          old_ground = Ground.find_by(:id => ground_id_was)
          old_ground.update(:num_citizen_cards => (old_ground.num_citizen_cards - 1))
        end
        if self.ground_id.present?
          new_ground = Ground.find_by(:id => ground_id)
          new_ground.update(:num_citizen_cards => (new_ground.num_citizen_cards + 1))
        end
      end
    end
end
