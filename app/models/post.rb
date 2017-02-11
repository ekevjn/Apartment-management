class Post < ActiveRecord::Base
  # relationship
  belongs_to :account

  # validation
  validates :title, presence: { message: "không được để trống" }
end
