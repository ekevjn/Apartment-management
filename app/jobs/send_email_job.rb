class SendEmailJob
  include SuckerPunch::Job

  def perform(email, title, content, subdomain)
    title += " - Thông báo từ chung cư #{Tower.find_by_subdomain(subdomain).name}"
    TowerMailer.send_mail(email, title, content).deliver
  end
end
