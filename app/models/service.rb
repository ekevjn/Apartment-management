class Service < ActiveRecord::Base
  extend CommonModule

  # business related to data
  before_save :calculate_fee_before_save

  # relationships
  belongs_to :ground

  # validation
  validates :ground_id, presence: { message: "không được để trống" }
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
  VNI_COLUMNS = { "ground_id" => "mặt bằng", "debt" => "nợ",
                  "paid" => "đã trả", "fee" => "phí",
                  "started_time" => "tháng tính phí" }

  # headers for export excel
  HEADERS = ["id",  "Mặt bằng", "Nợ",
    "Đã trả", "Phí", "Tháng tính phí", "Hiện tại"]

  HEADER_COLUMNS = %w(id ground_name debt paid fee
          started_time is_current_text)

  # methods
  def ground_name
    ground.name
  end

  def num_citizens
    ground.num_citizens
  end

  def area
    ground.area_length * ground.area_width
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
      Service.create!(
        ground_id: self.ground_id,
        debt: (remain - money),
        paid: 0,
        started_time: date,
        is_current: true,
        num_debt: (self.num_debt + 1)
      )
    elsif money == remain
      # restart paid, debt
      Service.create!(
        ground_id: self.ground_id,
        debt: 0,
        paid: 0,
        started_time: date,
        is_current: true,
        num_debt: 0
      )
    else
      # update paid, debt
      Service.create!(
        ground_id: self.ground_id,
        debt: 0,
        paid: (money - remain).to_i,
        started_time: date,
        is_current: true,
        num_debt: 0
      )
    end
  end

  def pay_enough
    # change is_current
    self.is_current = false
    self.save!
    # update paid, debt
    Service.create!(
      ground_id: self.ground_id,
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

  private
    def calculate_fee_before_save
      tower = Tower.find_by_subdomain(Apartment::Tenant.current)
      if tower.present?
        self.price_service = tower.price_service
        self.price_hygiene = tower.price_hygiene
      end
      sf = (ground.area_width * ground.area_length) * self.price_service + self.price_hygiene
      self.fee = sf.to_i
    end
end
