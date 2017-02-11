class SubdomainActivationJob
  include SuckerPunch::Job

  def perform(tower)
    TowerMailer.subdomain_activation(tower).deliver
  end
end
