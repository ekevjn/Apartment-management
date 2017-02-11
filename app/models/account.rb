class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable

  # relationships
  has_many :histories, dependent: :destroy

  # custom validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: "không được để trống" },
                    length: { maximum: 255, message: "email quá dài" },
                    format: { with: VALID_EMAIL_REGEX, message: "không đúng định dạng email" },
                    uniqueness: { case_sensitive: true, message: "email đã đưọc sử dụng" }
  validates :password, presence: { message: "không được để trống" },
                       length: { minimum: 5, maximum: 120, message: "mật khẩu phải nằm trong khoảng 5 - 120" },
                       on: :create

  validates :password, length: { minimum: 5, maximum: 120, message: "mật khẩu phải nằm trong khoảng 5 - 120" }, allow_blank: true,
                       on: :update

  validate do |g|
    if g.password.present?
      if g.password != g.password_confirmation
        g.errors.add(:password_confirmation, :not_specified, message: "xác nhận mật khẩu không khớp")
      end
    end
  end

  # attribute for update password
  attr_accessor :old_password

  # methods
  def is_manager_text
    if is_manager
      'Admin'
    else
      'Quản lí'
    end
  end

  def active_text
    if del_flg == 0
      "Đang hoạt động"
    else
      "Ngừng hoạt động"
    end
  end

  def active_for_authentication?
    super && (del_flg == 0)
  end
end
