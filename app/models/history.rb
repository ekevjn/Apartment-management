class History < ActiveRecord::Base
  belongs_to :account

  # headers for excel
  HEADERS = ["id",  "Tài khoản", "Nội dung" ]

  HEADER_COLUMNS = %w(id account_email content)

  def account_email
    account.email
  end

  def self.log(account, message, hash_changes=nil, hash_vni=nil)
    content = message
    begin
      # update case
      if hash_changes.present?
        hash_changes.each do |key, value|
          content += " thay đổi #{hash_vni[key]} từ #{value[0]} sang #{value[1]};"
        end
      end
    rescue Exception => msg
      content = " bị lỗi khi log: #{msg}"
    end
    History.create!(account_id: account.id, content: content)
  end

  def self.search(search)
    if search
      where("lower(content) like :content", { :content => "%#{search.downcase}%" })
    else
      all
    end
  end
end
