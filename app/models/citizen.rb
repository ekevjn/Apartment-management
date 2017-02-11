class Citizen < ActiveRecord::Base
  extend CommonModule
  after_create :check_ground_after_create
  before_save { self.email = email.downcase }

  # relationships
  belongs_to :ground
  has_many   :vehicle_cards
  has_many   :ground_histories

  # validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: { message: "không được để trống" }
  validates :email, length: { maximum: 255,
                              message: "email quá dài" },
                    format: { with: VALID_EMAIL_REGEX,
                              message: "email không hợp lệ" },
                    uniqueness: { case_sensitive: true,
                                  message: "email đã được sử dụng" },
                    allow_blank: true
  validates :dob, presence: { message: "không được để trống" }
  validates :government_id, uniqueness: { case_sensitive: true,
                                          message: "chứng minh thư đã được sử dụng"},
                            allow_blank: true
  validates :gender, presence: { message: "không được để trống" }
  validates :hometown, presence: { message: "không được để trống" }
  validates :nationality, presence: { message: "không được để trống" }

  validate do |g|
    if g.dob.present? && g.dob > Date.today
      g.errors.add(:dob, "không được lớn hơn ngày hiện tại")
    end
  end

  # hash for convert eng to vni
  VNI_COLUMNS = { "name" => "tên cư dân", "ground_id" => "mặt bằng",
                  "phone" => "điện thoại", "email" => "email",
                  "gender" => "giới tính", "dob" => "ngày sinh",
                  "nationality" => "quốc tịch", "is_water_deal" => "hưởng ưu đãi" }

  # headers for excel
  HEADERS = ["id",  "Tên cư dân", "Mặt bằng", "Điện thoại",
    "Email", "Giới tính", "Ngày sinh", "Chứng minh thư",
    "Quê quán", "Quốc tịch", "Hưởng ưu đãi", "Hoạt động"]

  HEADER_COLUMNS = %w(id name ground_name phone email
               gender_text dob_text government_id hometown
               nationality is_water_deal_text active_text)

  HEADERS_TEMPLATE = ["Tên cư dân", "Mặt bằng",
    "Điện thoại", "Email", "Giới tính", "Ngày sinh",
    "Chứng minh thư", "Quê quán", "Quốc tịch", "Hưởng ưu đãi"]

  HEADER_COLUMNS_TEMPLATE = %w(name ground_id phone email gender
    dob government_id hometown nationality is_water_deal)

  STATUS = ["Còn trống", "Đã mua", "Đang sử dụng"].freeze
  STATUS_CREATE = ["Còn trống", "Đã mua"].freeze

  # methods
  def ground_name
    if ground.present?
      ground.name
    else
      ''
    end
  end

  def gender_text
    if gender.present? && gender == 1
      'Nam'
    elsif gender.present? && gender == 0
      'Nữ'
    else
      ''
    end
  end

  def is_water_deal_text
    if is_water_deal
      'Có'
    else
      'Không'
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

  def dob_text
    if dob.present?
      dob.strftime("%d/%m/%Y")
    else
      ''
    end
  end

  def age
    if dob.present?
      Date.today.year - self.dob.year
    else
      ''
    end
  end

  def self.search(search)
    if search
      grounds = Ground.all.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      where("lower(name) like :name or ground_id in (:arr) or lower(email) like :email",
        { :name => "%#{search.downcase}%", :arr => grounds.map(&:id), :email => "%#{search.downcase}%"})
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
        begin
          record.dob = Date.strptime(row["dob"], "%d/%m/%Y") if row["dob"].present?
        rescue Exception
          raise Exception.new("Row thứ #{i} bị lỗi: Định dạng ngày sinh không chính xác. Bạn nên để format là text và định dạng là dd/MM/yyyy")
        end
        record.is_water_deal = true if row["is_water_deal"] == "có"
        if row["gender"].downcase == 'nam'
          record.gender = 1
        elsif row["gender"].downcase == 'nữ'
          record.gender = 0
        else
          raise Exception.new("Row thứ #{i} bị lỗi: Giới tính không xác định")
        end

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
     name: name,
     ground_name: (ground_name.present? ? ground_name : "Chưa có" ),
     value: name + " - " + dob.strftime("%d/%m/%Y")
   }
  end

  private
    def check_ground_after_create
      if self.ground_id.present?
        ground.owner_id = self.id if ground.num_citizens == 0
        ground.num_citizens += 1
        ground.num_water_deal += 1 if self.is_water_deal
        ground.save!
      end
    end
end

