class InforServiceJob
  include SuckerPunch::Job

  def perform(service, subdomain)
    Apartment::Tenant.switch!(subdomain)
    TowerMailer.infor_service_payment(service).deliver
  end
end
