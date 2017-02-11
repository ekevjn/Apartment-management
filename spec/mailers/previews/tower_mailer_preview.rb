# Preview all emails at http://localhost:3000/rails/mailers/tower_mailer
class TowerMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/tower_mailer/subdomain_activation
  def subdomain_activation
    tower = Tower.first
    tower.activation_token = Tower.new_token
    TowerMailer.subdomain_activation(tower)
  end

  # Preview this email at http://localhost:3000/rails/mailers/tower_mailer/infor_payment
  def infor_payment
    service = Service.new
    service.debt = 150
    service.paid = 100
    service.fee = 200
    service.started_time = Date.today
    service.ground_id = Ground.first.id
    TowerMailer.infor_payment(service)
  end

  # Preview this email at http://localhost:3000/rails/mailers/tower_mailer/infor_service_payment
  def infor_service_payment
    service = Service.new
    service.debt = 150
    service.paid = 100
    service.fee = 200
    service.started_time = Date.today
    service.ground_id = Ground.first.id
    TowerMailer.infor_service_payment(service)
  end

  # Preview this email at http://localhost:3000/rails/mailers/tower_mailer/infor_water_payment
  def infor_water_payment
    water = Water.new
    water.debt = 150
    water.paid = 100
    water.fee = 200
    water.started_time = Date.today
    water.ground_id = Ground.first.id
    TowerMailer.infor_water_payment(water)
  end

  # Preview this email at http://localhost:3000/rails/mailers/tower_mailer/infor_vehicle_payment
  def infor_vehicle_payment
    vehicle_finance = VehicleFinance.new
    vehicle_finance.debt = 150
    vehicle_finance.paid = 100
    vehicle_finance.fee = 200
    vehicle_finance.vehicle_card_id = VehicleCard.first.id
    vehicle_finance.started_time = Date.today
    vehicle_finance.vehicle_card.ground_id = Ground.first.id
    TowerMailer.infor_vehicle_payment(vehicle_finance)
  end

end
