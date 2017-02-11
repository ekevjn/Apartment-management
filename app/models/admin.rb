class Admin < ActiveRecord::Base
  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: "không được để trống" },
                    length: { maximum: 255, message: "quá dài" },
                    format: { with: VALID_EMAIL_REGEX,
                              message: 'không đúng định dạng' },
                    uniqueness: { case_sensitive: false,
                                  message: 'đã được sử dụng' }
  has_secure_password
  validates :password, presence: { message: "không được để trống" },
     length: {minimum: 6, message: 'ít nhật 6 kí tự' }

end
