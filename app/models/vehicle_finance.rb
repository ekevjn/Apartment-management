class VehicleFinance < ActiveRecord::Base
  extend CommonModule

  # business related to data
  before_validation :set_ground_before_validate
  before_save :calculate_fee_before_save

  # relationships
  belongs_to :vehicle_card
  belongs_to :ground

  # validation
  validates :vehicle_card_id, presence: { message: "không được để trống" }
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
  VNI_COLUMNS = { "vehicle_card_id" => "id thẻ", "ground_id" => "mặt bằng",
                  "debt" => "nợ", "paid" => "đã trả",
                  "fee" => "phí", "started_time" => "tháng tính phí" }

  # headers for export excel
  HEADERS = ["id",  "Số thẻ xe", "Mặt bằng",  "Số xe", "Nợ",
    "Đã trả", "Phí", "Tháng tính phí", "Hiện tại"]

  HEADER_COLUMNS = %w(id card_no ground_name license_no debt paid fee
          started_time is_current_text)

  # methods
  def ground_name
    if vehicle_card.ground.present?
      vehicle_card.ground.name
    else
      ''
    end
  end

  def card_no
    if vehicle_card.present?
      vehicle_card.card_no
    else
      ''
    end
  end

  def license_no
    if vehicle_card.present?
      vehicle_card.license_no
    else
      ''
    end
  end

  def is_current_text
    if is_current
      "Có"
    else
      "Không"
    end
  end

  def remain
    debt + fee - paid
  end

  def pay(money)
    # change is_current
    self.is_current = false
    self.save!
    # create new service record
    date = Date.today.next_month.change(:day => 1)
    if money < remain
      # when close finance
      VehicleFinance.create!(
        vehicle_card_id: self.vehicle_card_id,
        debt: (remain - money),
        paid: 0,
        started_time: date,
        is_current: true,
        num_debt: (self.num_debt + 1)
      )
    elsif money == remain
      # restart paid, debt
      VehicleFinance.create!(
        vehicle_card_id: self.vehicle_card_id,
        debt: 0,
        paid: 0,
        started_time: date,
        is_current: true,
        num_debt: 0
      )
    else
      # update paid, debt
      VehicleFinance.create!(
        vehicle_card_id: self.vehicle_card_id,
        debt: 0,
        paid: (money - remain),
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
    VehicleFinance.create!(
      vehicle_card_id: self.vehicle_card_id,
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
      vehicle_cards = VehicleCard.all.where("lower(card_no) like :card_no or lower(license_no) like :license_no",
        { :card_no => "%#{search.downcase}%", :license_no => "%#{search.downcase}%" })
      where("ground_id in (:ground_ids) or vehicle_card_id in (:vehicle_card_ids)",
        { :ground_ids => grounds.map(&:id), :vehicle_card_ids => vehicle_cards.map(&:id) })
    else
      all
    end
  end

  private
    def set_ground_before_validate
      self.ground_id = vehicle_card.ground.id if self.vehicle_card_id.present?
    end

    def calculate_fee_before_save
      tower = Tower.find_by_subdomain(Apartment::Tenant.current)
      if tower.present?
        if vehicle_card.vehicle_type == VehicleCard::TYPE_BICYCLE
          self.fee = tower.price_bicycle.to_i
        elsif vehicle_card.vehicle_type == VehicleCard::TYPE_ELECTRIC_BICYCLE
          self.fee = tower.price_electric_bicycle.to_i
        elsif vehicle_card.vehicle_type == VehicleCard::TYPE_MOTORBIKE
          self.fee = tower.price_motorbike.to_i
        elsif vehicle_card.vehicle_type == VehicleCard::TYPE_CAR_4_SEAT
          self.fee = tower.price_car_4_seat.to_i
        elsif vehicle_card.vehicle_type == VehicleCard::TYPE_CAR_7_SEAT
          self.fee = tower.price_car_7_seat.to_i
        else
          self.fee = 0
        end
      end
    end
end
