module GroundsHelper

  # check a ground finish paying finances or not
  def exist_finances?(ground)
    current_service(ground).present? || current_water(ground).present? || current_vehicle_finances(ground).present?
  end

  # check current finances for service
  def current_service(ground)
    Service.find_by('ground_id = :ground_id and is_current = true and ' +
              'extract(month from started_time) = :month AND extract(year from started_time) = :year',
              {:ground_id => ground.id, :month => Date.today.month, :year => Date.today.year})
  end

  # check current finances for water
  def current_water(ground)
    Water.find_by('ground_id = :ground_id and is_current = true and ' +
              'extract(month from started_time) = :month AND extract(year from started_time) = :year',
              {:ground_id => ground.id, :month => Date.today.month, :year => Date.today.year})
  end

  # check all current vehicle finances
  def current_vehicle_finances(ground)
    VehicleFinance.where('ground_id = :ground_id and is_current = true and ' +
              'extract(month from started_time) = :month AND extract(year from started_time) = :year',
              {:ground_id => ground.id, :month => Date.today.month, :year => Date.today.year})
  end

  # return true if  exist current vehicle finances
  def exist_vehicle_finances?(vehicle_card)
    current_finance_by_card(vehicle_card).present?
  end

  # check current finances for vehicle finance by card id
  def current_finance_by_card(vehicle_card)
    VehicleFinance.find_by('vehicle_card_id = :vehicle_card_id and is_current = true and ' +
              'extract(month from started_time) = :month AND extract(year from started_time) = :year',
              {:vehicle_card_id => vehicle_card.id, :month => Date.today.month, :year => Date.today.year})
  end

  # check current finance before delete ground.
  # return true if not pay yet
  def delete_ground(ground)
    isDone = true
    service = current_service(ground)
    water = current_water(ground)
    vehicle_finances = current_vehicle_finances(ground)
    if service.present? && (service.paid < (service.debt + service.fee))
      isDone = false
      flash.now[:danger] = "Không thể hủy, mặt bằng #{ground.name} vẫn chưa thanh toán xong phí chung"
    end
    if isDone && water.present? && (water.paid < (water.debt + water.fee))
      isDone = false
      flash.now[:danger] = "Không thể hủy, mặt bằng #{ground.name} vẫn chưa thanh toán xong phí nước"
    end
    if isDone && vehicle_finances.present?
      isDone = false
      flash.now[:danger] = "Không thể hủy, mặt bằng #{ground.name} vẫn chưa thanh toán xong phí nước"
    end
    return isDone
  end

  # open service, water for ground, change status after open
  def open_service(ground)
    ActiveRecord::Base.transaction do
      Service.create!(
        ground_id: ground.id,
        debt: 0,
        paid: 0,
        started_time: Date.today.change(:day => 1),
        is_current: true
      )
      Water.create!(
        ground_id: ground.id,
        water_no: 0,
        debt: 0,
        paid: 0,
        started_time: Date.today.change(:day => 1),
        is_current: true
      )
      ground.update(:status => Ground::STATUS_USED)
    end
  end

  # update status after close service
  def close_service(ground)
    ground.update(:status => Ground::STATUS_BOUGHT)
  end

  # open vehicle finance for vehicle card, update status vehicle card and ground after open
  def open_vehicle_finance(vehicle_card)
    VehicleFinance.create!(
      vehicle_card_id: vehicle_card.id,
      debt: 0,
      paid: 0,
      started_time: Date.today.change(:day => 1),
      is_current: true,
      num_debt: 0
    )
    vehicle_card.update(:status => VehicleCard::STATUS_AVAILABLE)
    vehicle_card.ground.update(:status => Ground::STATUS_USED)
  end
end
