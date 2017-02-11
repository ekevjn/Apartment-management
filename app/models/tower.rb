class Tower < ActiveRecord::Base
  extend CommonModule
  attr_accessor :activation_token
  after_create :create_tenant
  after_update :change_email_after_update
  before_save { self.email = email.downcase }
  before_create :create_activation_digest

  # validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: { message: "không được để trống" }
  validates :subdomain, presence: { message: "không được để trống" },
                        uniqueness: { case_sensitive: true,
                                      message: "đã đưọc sử dụng" }
  validates :email, presence: { message: "không được để trống" },
                    length: { maximum: 255, message: "email quá dài" },
                    format: { with: VALID_EMAIL_REGEX,
                              message: "không đúng format email" },
                    uniqueness: { case_sensitive: true,
                                  mesage: "đã đưọc sử dụng" }
  validates :manager_name, presence: { message: "không được để trống" }
  validates :phone, presence: { message: "không được để trống" }
  validates :payment_date, numericality: { greater_than_or_equal_to: 1,
                                    less_than_or_equal_to: 28,
                                    message: "phải là ngày từ 1 đến 28" }
  validates :price_service, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :price_hygiene, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :price_water_lv1, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :price_water_lv2, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :price_water_lv3, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :price_bicycle, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :price_electric_bicycle, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :price_motorbike, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :price_car_4_seat, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validates :price_car_7_seat, numericality: { greater_than_or_equal_to: 0,
                                    message: "phải là 1 số lớn hơn 0" }
  validate  :picture_size

  # uploader for tower picture
  mount_uploader :picture, PictureUploader
  # use for digest password
  has_secure_password

  # hash for convert eng to vni
  VNI_COLUMNS = { "name" => "tên chung cư", "subdomain" => "subdomain",
                  "area" => "diện tích",  "address" => "địa chỉ",
                  "phone" => "điện thoại", "email" => "email",
                  "symbol" => "kí hiệu", "fax" => "fax",
                  "taxcode" => "taxcode", "status" => "tình trạng",
                  "manager_name" => "người quản lí", "management_board" => "ban quản trị",
                  "bank_no" => "số tài khoản", "receiver_name" => "người nhận",
                  "bank_name" => "tên ngân hàng", "bank_eng" => "tên ngân hàng tiếng anh" }

  # headers for excel
  HEADERS = ["id",  "Tên chung cư", "Subdomain", "Diện tích",
    "Địa chỉ", "Điện thoại", "Email", "Kí hiệu",
    "Fax", "Taxcode", "Tình trạng", "Người sở hữu",
    "Ban quản trị", "Số tài khoản", "Người nhận",
    "Tên ngân hàng", "Tên ngân hàng (tiếng anh)", "Hoạt động" ]

  HEADER_COLUMNS = %w(id name subdomain area address
        phone email symbol fax taxcode status
        manager_name management_board bank_no
        receiver_name bank_name bank_eng active_text)

  HEADERS_TEMPLATE = ["Tên chung cư", "Subdomain", "Diện tích",
    "Địa chỉ", "Điện thoại", "Email", "Kí hiệu",
    "Fax", "Taxcode", "Tình trạng", "Người sở hữu",
    "Ban quản trị", "Số tài khoản", "Người nhận",
    "Tên ngân hàng", "Tên ngân hàng (tiếng anh)" ]

  HEADER_COLUMNS_TEMPLATE = %w(name subdomain area address
        phone email symbol fax taxcode status
        manager_name management_board bank_no
        receiver_name bank_name bank_eng )

  # methods for token
  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns true if the given token matches the digest.
  def authenticated?(activation_token)
    BCrypt::Password.new(activation_digest).is_password?(activation_token)
  end

  # methods
  def active
    del_flg == 0
  end

  def active_text
    if del_flg == 0
      "Đang hoạt động"
    else
      "Không hoạt động"
    end
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
      towers_search_term = TowersSearchTerm.new(search)
      where(towers_search_term.where_clause,
            towers_search_term.where_args)
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
        record.password = 'password'
        record.password_confirmation = 'password'
        record.del_flg = 0
        if record.save
          count += 1
        else
          raise Exception.new("Row thứ #{i} bị lỗi: #{record.errors.full_messages}")
        end
      end
      return count
    end
  end

  private
    def create_tenant
      Apartment::Tenant.create(subdomain)
      Apartment::Tenant.switch!(subdomain)
      Account.create!(email: email,
                  password: password,
                  password_confirmation: password_confirmation,
                  is_manager: true)
      Apartment::Tenant.switch!
    end

    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end

    def change_email_after_update
      if self.email_changed?
        Apartment::Tenant.switch!(subdomain)
        Account.create!(email: self.email,
                    password: 'password',
                    password_confirmation: 'password',
                    is_manager: true)
        Account.find_by(:is_manager => true).destroy
        Apartment::Tenant.switch!
      end
    end

    def create_activation_digest
      # Create the token and digest.
      self.activation_token  = Tower.new_token
      self.activation_digest = Tower.digest(activation_token)
    end
end
