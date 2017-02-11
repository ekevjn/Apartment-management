class InforVehicleJob
  include SuckerPunch::Job

  def perform(vehicle_finance, subdomain)
    Apartment::Tenant.switch!(subdomain)
    TowerMailer.infor_vehicle_payment(vehicle_finance).deliver
  end
end
