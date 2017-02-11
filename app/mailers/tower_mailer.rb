class TowerMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.tower_mailer.infor_payment.subject
  #
  def subdomain_activation(tower)
    @tower = tower
    mail to: tower.email, subject: "Xác nhận đăng ký chung cư"
  end

  def send_mail(email, title, content)
    @content = content
    mail to: email, subject: "#{title}"
  end

  # def infor_payment(service)
  #   @service = service
  #   @owner = Citizen.find_by_id(@service.ground.owner_id)
  #   mail to: 'ngochuydev@gmail.com'
  # end

  def infor_service_payment(service)
    @service = service
    @owner = Citizen.find_by_id(@service.ground.owner_id)
    mail to: @owner.email, subject: "Thông báo đã thanh toán xong phí chung của chung cư" if @owner.email.present?
  end

  def infor_water_payment(water)
    @water = water
    @owner = Citizen.find_by_id(@water.ground.owner_id)
    mail to: @owner.email, subject: "Thông báo đã thanh toán xong phí nước của chung cư" if @owner.email.present?
  end

  def infor_vehicle_payment(vehicle_finance)
    @vehicle_finance = vehicle_finance
    @type = @vehicle_finance.vehicle_card.vehicle_type
    @owner = Citizen.find_by_id(@vehicle_finance.vehicle_card.ground.owner_id)
    mail to: @owner.email, subject: "Thông báo đã thanh toán xong phí xe của chung cư" if @owner.email.present?
  end
end
