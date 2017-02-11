class Ground < ActiveRecord::Base
  extend CommonModule
  # uploader for ground images
  mount_uploaders :images, PictureUploader

  # business related to data
  before_create :status_empty_before_create
  before_update :update_status_with_owner_before_update
  after_create :update_citizen_after_create
  after_update :update_citizen_after_update

  # relationships
  belongs_to :building
  has_many   :citizens
  has_many   :citizen_cards
  has_many   :services
  has_many   :waters
  has_many   :vehicle_cards
  has_many   :vehicle_finances
  has_many   :ground_histories

  # constants for status
  STATUS_EMPTY  = "Còn trống"
  STATUS_BOUGHT = "Đã mua"
  STATUS_USED   = "Đang sử dụng"

  STATUS        = [ STATUS_EMPTY, STATUS_BOUGHT, STATUS_USED ].freeze
  STATUS_CREATE = [ STATUS_EMPTY, STATUS_BOUGHT ].freeze

  # validations
  validates :building_id, presence: { message: "không được để trống" }
  validates :name, presence: { message: "không được để trống" },
                   uniqueness: { case_sensitive: true,
                                 message: "đã đưọc sử dụng" }
  validates :status, inclusion: { in: STATUS,
                     message: "chọn trạng thái không thích hợp" }
  validates :kind, presence: { message: "không được để trống" }
  validates :floor, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :area_length, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :area_width, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :num_rooms, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :num_citizens, numericality: { allow_nil: true,
                                    greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :num_citizen_cards, numericality: { allow_nil: true,
                                    greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :num_water_deal, numericality: { allow_nil: true,
                                    greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validate do |g|
    if g.building_id.present?
      b = Building.find_by(:id => g.building_id)
      if b.present? && g.floor.present? && g.floor > b.num_floors
        g.errors.add(:floor, :not_specified, message: "tòa nhà #{b.name} chỉ có #{b.num_floors} tầng")
      end
    end
  end

  # hash for convert eng to vni
  VNI_COLUMNS = { "name" => "tên mặt bằng", "kind" => "loại",
                  "status" => "tình trạng",  "area_length" => "chiều dài",
                  "area_width" => "chiều rộng", "floor" => "tầng",
                  "building_id" => "tên tòa nhà", "owner_id" => "chủ sở hữu",
                  "num_rooms" => "số phòng" }

  # headers for excel
  HEADERS = ["id",  "Mặt bằng", "Loại",
    "Trạng thái", "Chiều dài", "Chiều rộng", "Tầng",
    "Tòa nhà", "Chủ sở hữu", "Sô phòng", "Số cư dân",
    "Số thẻ cư dân", "Số hưởng ưu đãi", "Hoạt động"]

  HEADER_COLUMNS = %w(id name kind status area_length area_width
               floor building_name owner_name
               num_rooms num_citizens num_citizen_cards
               num_water_deal active_text)

  HEADERS_TEMPLATE = ["Mặt bằng", "Loại", "Chiều dài",
    "Chiều rộng", "Tầng", "Tòa nhà", "Sô phòng" ]

  HEADER_COLUMNS_TEMPLATE = %w(name kind area_length
    area_width floor building_id num_rooms)

  # headers for import owner
  HEADERS_TEMPLATE_OWNER = ["Mặt bằng", "Tên chủ hộ" ]

  HEADER_COLUMNS_TEMPLATE_OWNER = %w(name owner_id)

  # methods
  def area
    "#{area_length} x #{area_width}"
  end

  def building_name
    if building.present?
      building.name
    else
      ''
    end
  end

  def owner_name
    c = Citizen.find_by_id(owner_id)
    if c.present?
      c.name
    else
      ''
    end
  end

  def active_text
    if del_flg == 0
      "Đang hoạt động"
    else
      "Không hoạt động"
    end
  end

  def active
    del_flg == 0
  end

  def active=(value)
    if value == '1'
      self.del_flg = 0
    else
      self.del_flg = 1
    end
  end

  def citizen_list
    Citizen.all.where("ground_id = :ground_id", :ground_id => self.id )
  end

  # business for change owner
  def change_owner(citizen)
  end

  def self.search(search)
    if search
      buildings = Building.all.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      citizens = Citizen.all.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      where("lower(name) like :name or building_id in (:arr) or owner_id in (:arr2) or lower(kind) like :kind",
        { :name => "%#{search.downcase}%", :arr => buildings.map(&:id),
          :arr2 => citizens.map(&:id), :kind => "%#{search.downcase}%"})
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
        b = Building.find_by(:name => row["building_id"])
        if b.present?
          record.building_id = b.id
        else
          raise Exception.new("Row thứ #{i} bị lỗi: Tòa nhà không tồn tại")
        end
        # convert to integer if floor is an integer
        record.floor = (is_integer(row["floor"]) ? row["floor"].to_i : row["floor"])
        if record.save
          count += 1
        else
          raise Exception.new("Row thứ #{i} bị lỗi: #{record.errors.full_messages}")
        end
      end
      raise Exception.new("Không có dữ liệu để thêm mặt bằng") if count == 0
    end
    return count
  end

  # import owner
  def self.import_owner(file)
    spreadsheet = open_spreadsheet(file)
    if HEADERS_TEMPLATE_OWNER != spreadsheet.row(1)
      raise Exception.new("Template không chính xác")
    end
    count = 0
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[HEADER_COLUMNS_TEMPLATE_OWNER, spreadsheet.row(i)].transpose]
      g = Ground.find_by(:name => row["name"])
      citizens = Citizen.where(:name => row["owner_id"])
      if g.blank?
        raise Exception.new("Row thứ #{i} bị lỗi: Mặt bằng không tồn tại")
      elsif exist_finances?(g)
        raise Exception.new("Row thứ #{i} bị lỗi: Mặt bằng này chưa thanh toán xong các dịch vụ. Không thể đổi chủ")
      elsif citizens.blank?
        raise Exception.new("Row thứ #{i} bị lỗi: Cư dân không tồn tại")
      elsif citizens.count > 1
        raise Exception.new("Row thứ #{i} bị lỗi: Tồn tại ít nhất 1 cư dân trùng tên. Vui lòng nhập bằng tay cư dân này")
      elsif Ground.find_by(:owner_id => citizens.first.id)
        raise Exception.new("Row thứ #{i} bị lỗi: Cư dân này hiện đang là chủ hộ của mặt bằng khác. Cần đổi chủ hộ mặt bằng này trưóc")
      elsif !g.update(:owner_id => citizens.first.id)
        raise Exception.new("Row thứ #{i} bị lỗi: #{g.errors.full_messages}")
      else
        count += 1
      end
    end
    raise Exception.new("Không có dữ liệu để cập nhật") if count == 0
    return count
  end

  # json for autocomplete
  def as_json options={}
   {
     key: id,
     value: name
   }
  end

  private
    # mặt bằng luôn còn trống nếu tạo record mới
    def status_empty_before_create
      self.status = STATUS_EMPTY
    end

    # thay đổi trạng thái khi đổi chủ hộ
    def update_status_with_owner_before_update
      if self.owner_id_changed?
        # thay đổi trạng thái mặt bằng
        if self.status == STATUS_EMPTY && self.owner_id.present?
          # khi chủ hộ vào mặt bằng trống => đã mua
          self.status = STATUS_BOUGHT
        elsif self.status == STATUS_BOUGHT && self.owner_id.blank?
          # khi chủ hộ rời đi ( đã thanh toán xong ) => còn trống
          self.status = STATUS_EMPTY
          # khi chủ hộ cũ thanh toán xong, đổi chủ cũ bằng chủ mới (chưa mở dịch vụ)
          # => status vẫn là đã mua
        end

        # lưu lịch sử đổi chủ hộ
        # cập nhật lịch sử ngày đi của chủ hộ cũ
        if self.owner_id_was.present?
          owner_olds = GroundHistory.where(:ground_id => self.id).
                                      order(ground_id: :desc)
          if owner_olds.present?
            owner_old = owner_olds.first
            owner_old.end_date = Date.today
            owner_old.save
          end
        end
        # tạo mới lịch sử cho chủ hộ mới
        if self.owner_id.present?
          owner_new = GroundHistory.new(:ground_id => self.id,
                          :citizen_id => self.owner_id)
          owner_new.come_date = Date.today
          owner_new.save
        end
      end
    end

    # update ground of citizen if ground has owner
    def update_citizen_after_create
      if self.owner_id.present?
        citizen = Citizen.find_by_id(self.owner_id)
        citizen.ground_id = self.id
        citizen.save!
      end
    end

    # update ground of citizen if owner changed
    def update_citizen_after_update
      if self.owner_id_changed? && self.owner_id.present?
        citizen = Citizen.find_by_id(self.owner_id)
        citizen.ground_id = self.id
        citizen.save!
      end
    end
end
