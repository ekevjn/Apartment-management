class VehicleCard < ActiveRecord::Base
  extend CommonModule

  # business related to data
  before_create :status_created_before_create

  # relationships
  belongs_to :ground
  belongs_to :citizen
  has_many :vehicle_finances

  # constants for status
  STATUS_CREATED = 'Mới tạo'
  STATUS_AVAILABLE = 'Đang sử dụng'
  STATUS_LOST = 'Bị mất'
  STATUS_LOCK = 'Khóa thẻ'
  # constants for vehicle type
  TYPE_BICYCLE = 'Xe đạp'
  TYPE_ELECTRIC_BICYCLE = 'Xe đạp điện'
  TYPE_MOTORBIKE = 'Xe máy'
  TYPE_CAR_4_SEAT = 'Ô tô (4 chỗ)'
  TYPE_CAR_7_SEAT = 'Ô tô (7 chỗ)'

  STATUS = [ STATUS_CREATED, STATUS_AVAILABLE, STATUS_LOST, STATUS_LOCK ].freeze
  VEHICLE_TYPE = [ TYPE_BICYCLE, TYPE_ELECTRIC_BICYCLE, TYPE_MOTORBIKE,
                   TYPE_CAR_4_SEAT, TYPE_CAR_7_SEAT ].freeze

  # validation
  validates :card_no, presence: { message: "không được để trống" },
                      uniqueness: { case_sensitive: true,
                                    message: "đã đưọc sử dụng" }
  validates :license_no, presence: { message: "không được để trống" },
                         uniqueness: { case_sensitive: true,
                                       message: "đã đưọc sử dụng" }
  validates :ground_id, presence: { message: "không được để trống" }
  validates :citizen_id, presence: { message: "không được để trống" }
  validates :vehicle_type, presence: { message: "không được để trống" },
                     inclusion: { in: VEHICLE_TYPE,
                                  message: "không hợp lệ" }
  validates :status, presence: { message: "không được để trống" },
                     inclusion: { in: STATUS,
                                  message: "trạng thái không thích hợp" }
  validates :created_fee, numericality: { allow_nil: true,
                     greater_than_or_equal_to: 0,
                     message: "phải là 1 số lớn hơn 0" }
  validate do |v|
    if v.ground_id.present? && v.citizen_id.present?
      g = Ground.find_by(:id => v.ground_id)
      c = Citizen.find_by(:id => v.citizen_id)
      if g.present? && c.present? && c.ground_id != g.id
        v.errors.add(:citizen_id, :not_specified, message: "cư dân #{c.name} không thuộc mặt bằng #{g.name}")
      end
    end
  end

  # hash for convert eng to vni
  VNI_COLUMNS = { "card_no" => "mã số thẻ", "license_no" => "số xe",
                  "vehicle_type" => "loại xe", "ground_id" => "mặt bằng",
                  "citizen_id" => "cư dân", "created_fee" => "phí tạo thẻ",
                  "registered_time" => "ngày đăng kí", "started_time" => "tháng tính phí",
                  "outdate_time" => "tháng hết hạn", "status" => "tình trạng",
                  "description" => "mô tả" }

  # headers for excel
  HEADERS = [ "id", "Mã số thẻ", "Số xe", "Loại xe", "Mặt bằng", "Cư dân",
    "Phí tạo thẻ","Ngày đăng kí", "Tháng tính phí",
    "Tháng hết hạn", "Tình trạng", "Mô tả" ]

  HEADER_COLUMNS = %w(id card_no license_no vehicle_type ground_name citizen_name
              created_fee registered_time_text started_time_text
              outdate_time_text status description )

  HEADERS_TEMPLATE = [ "Mã số thẻ", "Số xe", "Loại xe", "Mặt bằng", "Cư dân",
                       "Phí tạo thẻ","Ngày đăng kí", "Tháng tính phí",
                       "Tháng hết hạn", "Mô tả" ]

  HEADER_COLUMNS_TEMPLATE = %w(card_no license_no vehicle_type
              ground_id citizen_id created_fee registered_time
              started_time outdate_time description)

  # methods
  def ground_name
    if ground.present?
      ground.name
    else
      ''
    end
  end

  def citizen_name
    if citizen.present?
      citizen.name
    else
      ''
    end
  end

  def registered_time_text
    if registered_time.present?
      registered_time.strftime("%d/%m/%Y")
    else
      ''
    end
  end

  def started_time_text
    if started_time.present?
      started_time.strftime("%m/%Y")
    else
      ''
    end
  end

  def outdate_time_text
    if outdate_time.present?
      outdate_time.strftime("%m/%Y")
    else
      ''
    end
  end

  def self.search(search)
    if search
      grounds = Ground.all.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      where("ground_id in (:ground_ids) or lower(card_no) like :param or lower(license_no) like :param",
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
        citizens = Citizen.where(:name => row["citizen_id"])
        if citizens.blank?
          raise Exception.new("Row thứ #{i} bị lỗi: Không tìm thấy cư dân này")
        elsif citizens.count > 1
          raise Exception.new("Row thứ #{i} bị lỗi: Tồn tại ít nhất 1 cư dân trùng tên. Vui lòng nhập bằng tay cư dân này")
        else
          record.citizen_id = citizens.first.id
        end
        begin
          record.registered_time = Date.strptime(row["registered_time"], "%d/%m/%Y") if row["registered_time"].present?
        rescue Exception
          raise Exception.new("Row thứ #{i} bị lỗi: Định dạng ngày đăng kí không chính xác. Bạn nên để format là text và định dạng là dd/MM/yyyy")
        end
        begin
          record.started_time = Date.strptime(row["started_time"], "%m/%Y") if row["started_time"].present?
          record.outdate_time = Date.strptime(row["outdate_time"], "%m/%Y") if row["outdate_time"].present?
        rescue Exception
          raise Exception.new("Row thứ #{i} bị lỗi: Định dạng tháng tính phí hoặc tháng hết hạn không chính xác. Bạn nên để format là text và định dạng là MM/yyyy")
        end
        record.is_water_deal = true if row["is_water_deal"] == "có"
        if record.save
          count += 1
        else
          raise Exception.new("Row thứ #{i} bị lỗi: #{record.errors.full_messages}")
        end
      end
      raise Exception.new("Không có dữ liệu để thêm cư dân") if count == 0
    end
    return count
  end

  # json for autocomplete
  def as_json options={}
   {
     key: id,
     value: card_no + ' - ' + license_no
   }
  end

  private
    # thẻ xe luôn ở trạng thái vừa tạo nếu tạo record mới
    def status_created_before_create
      self.status = STATUS_CREATED
    end
end
