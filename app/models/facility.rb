class Facility < ActiveRecord::Base
  extend CommonModule
  # relationships
  belongs_to :building

  # facility status
  STATUS = ["Còn mới", "Đã sử dụng", "Bị hỏng" ].freeze
  STATUS_CREATE = ["Còn mới", "Đã sử dụng"].freeze

  # validations
  #validate :guarantee_time_cannot_be_in_the_past, :buy_time_cannot_be_in_the_future, :name_validation
  validates :building_id, presence: { message: "không được để trống" }
  validates :name, presence: { message: "không được để trống" },
                   uniqueness: { case_sensitive: true,
                                 message: "đã đưọc sử dụng" }
#        format: {with: /\A[a-zA-Z]*\z/, message: "Tên không hợp lệ"}
  validates :status, inclusion: { in: STATUS,
                                  message: "trạng thái không thích hợp" }
  validates :buy_time, presence: { message: "xin hãy chọn ngày mua tài sản" }
  validates :guarantee_time, presence: { message: "Xin hãy chọn ngày bảo hành của tài sản" }
  validates :position, presence: { message: "không được để trống" }
#        format: {with: /\A[a-zA-Z]*\z/, message: "Vị trí không hợp lệ"}

  # hash for convert eng to vni
  VNI_COLUMNS = { "name" => "tên tài sản", "status" => "trạng thái",
                  "position" => "vị trí",  "building_id" => "tòa nhà",
                  "buy_time" => "ngày mua", "guarantee_time" => "ngày hết bảo hành",
                  "guarantee_company" => "đơn vị bảo hành" }

  # headers for excel
  HEADERS = ["id", "Tên tài sản", "Trạng thái", "Vị trí", "Tòa nhà",
             "Ngày mua", "Ngày hết bảo hành", "Đơn vị bảo hành", "Hoạt động"]
  HEADER_COLUMNS = %w(id name status position building_name
                      buy_time_text guarantee_time_text guarantee_company active_text)
  HEADERS_TEMPLATE = ["Tên tài sản", "Vị trí", "Tòa nhà", "Ngày mua", "Ngày hết bảo hành", "Đơn vị bảo hành"]
  HEADER_COLUMNS_TEMPLATE = %w(name position building_id buy_time guarantee_time guarantee_company)

  def building_name
    if building.present?
      building.name
    else
      ''
    end
  end

  def buy_time_text
    if buy_time.present?
      buy_time.strftime("%d/%m/%Y")
    else
      ''
    end
  end

  def guarantee_time_text
    if guarantee_time.present?
      guarantee_time.strftime("%d/%m/%Y")
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

  def self.search(search)
    if search
      buildings = Building.all.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      where("lower(name) like :name or building_id in (:building_ids)",
        { :name => "%#{search.downcase}%", :building_ids => buildings.map(&:id) })
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
        begin
          record.buy_time = Date.strptime(row["buy_time"], "%d/%m/%Y") if row["buy_time"].present?
        rescue Exception
          raise Exception.new("Row thứ #{i} bị lỗi: Định dạng ngày mua không chính xác. Bạn nên để format là text và định dạng là dd/MM/yyyy")
        end

        begin
          record.guarantee_time = Date.strptime(row["guarantee_time"], "%d/%m/%Y") if row["guarantee_time"].present?
        rescue Exception
          raise Exception.new("Row thứ #{i} bị lỗi: Định dạng ngày hết bảo hành không chính xác. Bạn nên để format là text và định dạng là dd/MM/yyyy")
        end

        record.status = STATUS[0]
        if record.save
          count += 1
        else
          raise Exception.new("Row thứ #{i} bị lỗi: #{record.errors.full_messages}")
        end
      end
      raise Exception.new("Không có dữ liệu để thêm tài sản") if count == 0
    end
    return count
  end

  #VIETNAMESE_DIACRITIC_CHARACTERS = "ẮẰẲẴẶĂẤẦẨẪẬÂÁÀÃẢẠĐẾỀỂỄỆÊÉÈẺẼẸÍÌỈĨỊỐỒỔỖỘÔỚỜỞỠỢƠÓÒÕỎỌỨỪỬỮỰƯÚÙỦŨỤÝỲỶỸỴ"
  #VALID_VENAMESE_REGEX = Regexp.new("VIETNAMESE_DIACRITIC_CHARACTERS" + "]|[a-zA-Z])++", Regexp::IGNORECASE | Regexp::MULTILINE | Regexp::EXTENDED)

  def name_validation
    errors.add(:name, :invalid_characters, not_allowed: "!@#%*()_-+=", message: "Tên không hợp lệ")
  end

  def buy_time_cannot_be_in_the_future
    if buy_time.present? && buy_time > Date.today
      errors.add(:expiration_date, "Bạn không thể mua tài sản này từ tương lai! Vui lòng nhập lại ngày mua tài sản.")
    end
  end

  def guarantee_time_cannot_be_in_the_past
    if guarantee_time.present? && guarantee_time <= Date.today
      errors.add(:expiration_date, "Chúng ta không phải nhà thu mua phế lệu! vui lòng nhập lại ngày bảo hành của tài sản.")
    end
  end
end
