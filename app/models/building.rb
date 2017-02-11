class Building < ActiveRecord::Base
  extend CommonModule

  # relationship
  has_many :grounds
  has_many :facilities

  # validation
  validates :name, presence: { message: "không được để trống" },
                   uniqueness: { case_sensitive: true,
                                 message: "đã đưọc sử dụng" }
  validates :num_floors, numericality: { only_integer: true,
                greater_than_or_equal_to: 0,
                message: "phải là 1 số lớn hơn 0" }

  # hash for convert eng to vni
  VNI_COLUMNS = { "name" => "tên tòa nhà", "num_floors" => "số tầng" }

  # headers for excel
  HEADERS = ["id",  "Tòa nhà", "Số tầng", "Hoạt động" ]

  HEADER_COLUMNS = %w(id name num_floors active_text)

  HEADERS_TEMPLATE = ["Tòa nhà", "Số tầng" ]

  HEADER_COLUMNS_TEMPLATE = %w(name num_floors)

  # methods
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
      where("lower(name) like :name", { :name => "%#{search.downcase}%" })
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
        # convert to integer if num_floors is an integer
        record.num_floors = (is_integer(row["num_floors"]) ? row["num_floors"].to_i : row["num_floors"])
        if record.save
          count += 1
        else
          raise Exception.new("Row thứ #{i} bị lỗi: #{record.errors.full_messages}")
        end
      end
      raise Exception.new("Không có dữ liệu để thêm tòa nhà") if count == 0
    end
    return count
  end
end
