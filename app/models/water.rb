class Water < ActiveRecord::Base
  extend CommonModule

  # business related to data
  before_validation :check_water_no_before_create, on: :create
  before_validation :check_water_no_before_update, on: :update
  before_save :cal_fee_before_save

  # relationships
  belongs_to :ground
  validates :ground_id, presence: { message: "không được để trống" }
  validates :water_num, numericality: { only_integer: true,
                  greater_than_or_equal_to: 0,
                  message: "số khối nước không hợp lệ" }
  validates :water_no, numericality: { only_integer: true,
                  greater_than_or_equal_to: 0,
                  message: "chỉ số nước không hợp lệ" }
  validates :debt, numericality: { only_integer: true,
                  greater_than_or_equal_to: 0,
                  message: "số tiền không hợp lệ" }
  validates :paid, numericality: { only_integer: true,
                  greater_than_or_equal_to: 0,
                  message: "số tiền không hợp lệ" }
  validates :fee, numericality: { only_integer: true,
                  greater_than_or_equal_to: 0,
                  message: "số tiền không hợp lệ" }
  validates :num_debt, numericality: { only_integer: true,
                          greater_than_or_equal_to: 0,
                          message: "phải là 1 số lớn hơn 0" }
  validates :started_time, presence: { message: "không được để trống" }

  # hash for convert eng to vni
  VNI_COLUMNS = { "ground_id" => "mặt bằng", "water_num" => "số khối nước",
                  "debt" => "nợ", "paid" => "đã trả",
                  "fee" => "phí", "started_time" => "tháng tính phí" }

  # Headers for excel
  # user for export
  HEADERS = ["id",  "Mặt bằng", "Chỉ số nước", "Số khối nước trong tháng", "Nợ",
    "Đã trả", "Phí", "Tháng tính phí", "Hiện tại"]

  HEADER_COLUMNS = %w(id ground_name water_no water_num debt paid fee
          started_time is_current_text)

  # use for input water num
  HEADERS_TEMPLATE = ["Mặt bằng", "Chỉ số nưóc mới" ]

  HEADER_COLUMNS_TEMPLATE = %w(ground_id water_no)

  # methods
  def ground_name
    ground.name
  end

  def remain
    debt + fee - paid
  end

  def is_current_text
    if is_current
      "Có"
    else
      "Không"
    end
  end

  def pay(money)
    # change is_current
    self.is_current = false
    self.save!
    # create new service record
    date = Date.today.next_month.change(:day => 1)
    if money < remain
      # when close finance
      Water.create!(
        ground_id: self.ground_id,
        water_no: 0,
        debt: (remain - money),
        paid: 0,
        started_time: date,
        is_current: true,
        num_debt: (self.num_debt + 1)
      )
    elsif money == remain
      # restart paid, debt
      Water.create!(
        ground_id: self.ground_id,
        water_no: 0,
        debt: 0,
        paid: 0,
        started_time: date,
        is_current: true,
        num_debt: 0
      )
    else
      # update paid, debt
      Water.create!(
        ground_id: self.ground_id,
        water_no: 0,
        debt: 0,
        paid: (money - remain),
        started_time: date,
        is_current: true,
        num_debt: 0
      )
    end
  end

  def pay_enough
    self.is_current = false
    self.save!
    # update paid, debt
    Water.create!(
      ground_id: self.ground_id,
      water_no: 0,
      debt: 0,
      paid: 0,
      started_time: Date.today.next_month.change(:day => 1),
      is_current: true,
      num_debt: 0
    )
  end

  def payout
    self.is_current = false
    self.save!
  end

  def self.search(search)
    if search
      grounds = Ground.all.where("lower(name) like :name", { :name => "%#{search.downcase}%" })
      where(:ground_id => grounds.map(&:id))
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
        g = Ground.find_by(:name => row["ground_id"])
        if g.present?
          record = Water.find_by(:ground_id => g.id, :is_current => true)
          if record.started_time.month !=  Date.today.month
            raise Exception.new("Row thứ #{i} bị lỗi: Không tồn tại phí dịch vụ nước hiện tại của mặt bằng này")
          else
            record.water_num = (is_integer(row["water_no"]) ? row["water_no"].to_i : row["water_no"])
            if record.save
              count += 1
            else
              raise Exception.new("Row thứ #{i} bị lỗi: #{record.errors.full_messages}")
            end
          end
          record.ground_id = g.id
        else
          raise Exception.new("Row thứ #{i} bị lỗi: Mặt bằng không tồn tại")
        end
      end
      raise Exception.new("Không có dữ liệu để cập nhật") if count == 0
    end
    return count
  end

  private
    def cal_fee_water
      fee_water = 0
      if num_water_deal == 0
        # khong uu dai
        fee_water = self.price_water_lv3 * self.water_num
      elsif water_num <= (num_water_deal * 4)
        # 4 khoi dau
        fee_water = self.price_water_lv1 * self.num_water_deal * self.water_num
      elsif water_num <= (num_water_deal * 6)
        # 4 -> 6 khoi
        fee_water = self.price_water_lv1 * self.num_water_deal * 4 +
            self.price_water_lv2 * self.num_water_deal * (self.water_num - 4)
      else
        # tren 6 khoi
        fee_water = self.price_water_lv1 * self.num_water_deal * 4 +
            self.price_water_lv2 * self.num_water_deal * 2 +
            self.price_water_lv3 * self.num_water_deal * (self.water_num - 6)
      end
      return fee_water
    end

    def check_water_no_before_create
      if ground_id.present?
        waters = Water.where("ground_id = #{ground.id}").order(id: :desc)
      end
      if water_no.present? && waters.present?
        if water_no == 0
          self.water_no = waters.first.water_no
          self.water_num = self.water_no
        elsif water_no >= waters.first.water_no
          self.water_num = self.water_no - waters.first.water_no
        else
          errors.add(:water_no, :not_specified, message: "Chỉ số nước không hợp lệ vì nhỏ hơn tháng trước")
        end
      elsif water_no.present?
        self.water_num = self.water_no
      end
    end

    def check_water_no_before_update
      if ground_id.present?
        waters = Water.where("ground_id = #{ground.id} and id <> #{self.id}").order(id: :desc)
      end
      if water_no.present? && waters.present? && waters.first.water_no > water_no
        errors.add(:water_no, :not_specified, message: "Chỉ số nước không hợp lệ vì nhỏ hơn tháng trước")
      end
      if self.water_no.present?
        self.water_num = self.water_num + self.water_no - self.water_no_was
      end
    end

    def cal_fee_before_save
      if water_no_changed?
        tower = Tower.find_by_subdomain(Apartment::Tenant.current)
        if tower.present?
          self.price_water_lv1 = tower.price_water_lv1
          self.price_water_lv2 = tower.price_water_lv2
          self.price_water_lv3 = tower.price_water_lv3
        end
        self.num_water_deal = ground.num_water_deal
        self.fee = cal_fee_water
      end
    end
end
