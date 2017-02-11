class Maintain < ActiveRecord::Base
  extend CommonModule

  # relationships
  belongs_to :facility

  # validation
  validates :facility_id, presence: { message: "không được để trống" }
  validates :fixed_time, presence: { message: "không được để trống" }
  validates :price, numericality: { only_integer: true,
                          greater_than_or_equal_to: 0,
                          message: "phải là 1 số lớn hơn 0" }

  # hash for convert eng to vni
  VNI_COLUMNS = { "facility_id" => "tên tài sản", "fixed_time" => "ngày sửa chữa",
                  "price" => "giá tiền",  "description" => "mô tả" }

  # headers for excel
  HEADERS = ["id", "Tài sản", "Ngày sửa chữa", "Chi phí sửa chữa", "Mô tả"]
  HEADER_COLUMNS = %w(id facility_name fixed_time_text price description)
  HEADERS_TEMPLATE = ["Tài sản", "Ngày sửa chữa", "Chi phí sửa chữa", "Mô tả"]
  HEADER_COLUMNS_TEMPLATE = %w(facility_id fixed_time price description)

  def facility_name
    if facility.present?
      facility.name
    else
      ''
    end
  end

  def fixed_time_text
    if fixed_time.present?
      fixed_time.strftime("%d/%m/%Y")
    else
      ''
    end
  end

  def self.search(search)
    if search
      facilities = Facility.all.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      where("facility_id in (:facility_ids)",
        { :facility_ids => facilities.map(&:id) })
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
        f = Facility.find_by(:name => row["facility_id"])
        if f.present?
          record.facility_id = f.id
        else
          raise Exception.new("Row thứ #{i} bị lỗi: Tài sản không tồn tại")
        end
        begin
          record.fixed_time = Date.strptime(row["fixed_time"], "%d/%m/%Y") if row["fixed_time"].present?
        rescue Exception
          raise Exception.new("Row thứ #{i} bị lỗi: Định dạng ngày sửa chữa không chính xác. Bạn nên để format là text và định dạng là dd/MM/yyyy")
        end
        record.price = (is_integer(row["price"]) ? row["price"].to_i : row["price"])
        if record.save
          count += 1
        else
          raise Exception.new("Row thứ #{i} bị lỗi: #{record.errors.full_messages}")
        end
      end
      raise Exception.new("Không có dữ liệu để thêm bảo trì") if count == 0
    end
    return count
  end
end
