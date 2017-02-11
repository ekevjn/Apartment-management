class InforWaterJob
  include SuckerPunch::Job

  def perform(water, subdomain)
    Apartment::Tenant.switch!(subdomain)
    TowerMailer.infor_water_payment(water).deliver
  end
end
