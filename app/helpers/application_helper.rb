module ApplicationHelper
  # type of close finances
  FINANCES_CLOSED = 0
  FINANCES_CLOSING = 1
  FINANCES_NOT_CLOSE = 2

  # hash for ground
  VNI_TYPES = { "tower" => "chung cư", "ground" => "mặt bằng", "building" => "tòa nhà",
                "citizen" => "cư dân", "citizen_card" => "thẻ cư dân",
                "vehicle_card" => "thẻ xe", "vehicle_finance" => "phí xe",
                "service" => "phí chung", "water" => "phí nước",
                "facility" => "tài sản", "maintain" => "bảo trì"}

  def isSubDomain?
    request.subdomain.present? && request.subdomain != 'www'
  end

  def type_of_payment_day_close
    tower = Tower.find_by_subdomain(Apartment::Tenant.current)
    if tower.present?
      if !is_closed_finances(Date.today.last_month.month, Date.today.last_month.year)
        if Date.today.day >= 1  && Date.today.day <= tower.payment_date
          return ApplicationHelper::FINANCES_CLOSING
        else
          return ApplicationHelper::FINANCES_NOT_CLOSE
        end
      else
        return ApplicationHelper::FINANCES_CLOSED
      end
    end
  end

  # return true if already close finances
  def is_closed_finances(month, year)
    services = Service.where("is_current = true " +
                " AND extract(month from started_time) = #{month} " +
                " AND extract(year from started_time) = #{year}")
    waters = Water.where("is_current = true " +
                " AND extract(month from started_time) = #{month} " +
                " AND extract(year from started_time) = #{year}")
    vehicles = VehicleFinance.where("is_current = true " +
                " AND extract(month from started_time) = #{month} " +
                " AND extract(year from started_time) = #{year}")
    return services.blank? && waters.blank? && vehicles.blank?
  end

  def close_all_finances(month, year)
    is_close = true
    date = Date.today.change(:day => 1, :month => month, :year => year).next_month
    ActiveRecord::Base.transaction do
      services = Service.where("is_current = true " +
                  " AND extract(month from started_time) = #{month} " +
                  " AND extract(year from started_time) = #{year}")
      if services.present?
        services.each do | service |
          # change is_current
          service.is_current = false
          service.save!
          # create new service record
          Service.create!(
            ground_id: service.ground_id,
            debt: (service.debt + service.fee - service.paid),
            paid: 0,
            started_time: date,
            is_current: true,
            num_debt: (service.num_debt + 1)
          )
        end
      else
        is_close = false
      end
      waters = Water.where("is_current = true " +
                  " AND extract(month from started_time) = #{month} " +
                  " AND extract(year from started_time) = #{year}")
      if waters.present?
        waters.each do | water |
          # change is_current
          water.is_current = false
          water.save!
          # create new water record
          Water.create!(
            ground_id: water.ground_id,
            water_no: 0,
            debt: (water.debt + water.fee - water.paid),
            paid: 0,
            started_time: date,
            is_current: true,
            num_debt: (water.num_debt + 1)
          )
        end
      else
        is_close = false
      end
      vehicles = VehicleFinance.where("is_current = true " +
                  " AND extract(month from started_time) = #{month} " +
                  " AND extract(year from started_time) = #{year}")
      if vehicles.present?
        vehicles.each do | vehicle |
          # change is_current
          vehicle.is_current = false
          vehicle.save!
          # create new vehicle finance record
          VehicleFinance.create!(
            vehicle_card_id: vehicle.vehicle_card_id,
            debt: (vehicle.debt + vehicle.fee - vehicle.paid),
            paid: 0,
            started_time: date,
            is_current: true,
            num_debt: (vehicle.num_debt + 1)
          )
        end
      else
        is_close = false
      end
    end
    return is_close
  end

  def devise_error_messages!
    return '' if resource.errors.any?

    messages = resource.errors.full_messages.map {
      |msg| content_tag(:li, msg)
    }.join

    html = <<-HTML
      <div class="alert alert-error alert-danger">
      <a href="#" class="close" data-dismiss="alert" &215;></a>
      <%= content_tag :div, msg if msg.is_a?(String) %>
      </div>
      HTML
    html.html_safe
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge(:sort => column,
      :direction => direction, :page => nil ), { :class => css_class }
  end

  def list_active_building
    Building.where(:del_flg => 0)
  end

  def list_active_facility
    Facility.where(:del_flg => 0)
  end

  def number_to_vnd(number, unit=true)
    suffix = ""
    suffix = "VND" if unit
    number_to_currency(number, unit: suffix, delimiter: ".", precision: 0, format: "%n %u")
  end

  def is_integer(str)
    !!Integer(str)
  rescue ArgumentError, TypeError
    false
  end

  def is_finances(type)
    type == "water" || type == "service" || type == "vehicle_finance"
  end

  def is_card(type)
    type == "citizen_card" || type == "vehicle_card"
  end

  def filterable(type, name)
    name = VNI_TYPES[name]
    if type == 'all'
      title = "Tất cả " + name.titleize
    elsif type == 'active'
      title = name.titleize + " đang hoạt động"
    else
      title = name.titleize + " dừng hoạt động"
    end
    link_to title, params.merge(:type => type, :page => nil)
  end

  def month_filterable(filter_date)
    link_to "Tháng #{filter_date}", params.merge(:filter_date => filter_date, :page => nil)
  end

  def come_month_filterable(filter_date)
    link_to "#{filter_date}", params.merge(:come_date => filter_date, :page => nil)
  end

  def end_month_filterable(filter_date)
    link_to "#{filter_date}", params.merge(:end_date => filter_date, :page => nil)
  end

  def status_filterable(status)
    link_to "#{status}", params.merge(:status => status, :page => nil)
  end

  def filter_by_month(type)
    if type == "service"
      dates = Service.all.sort_by { |d| d.started_time.year }.map { |d| d.started_time.strftime('%m/%Y') }.uniq
    elsif type == "water"
      dates = Water.all.sort_by { |d| d.started_time.year }.map { |d| d.started_time.strftime('%m/%Y') }.uniq
    elsif type == "vehicle_finance"
      dates = VehicleFinance.all.sort_by { |d| d.started_time.year }.map { |d| d.started_time.strftime('%m/%Y') }.uniq
    elsif type == "history"
      dates = History.all.sort_by { |d| d.created_at.year }.map { |d| d.created_at.strftime('%m/%Y') }.uniq
    end
  end

  def filter_by_status(type)
    if type == "citizen_card"
      CitizenCard::STATUS
    elsif type == "vehicle_card"
      VehicleCard::STATUS
    end
  end

  def name_modal(type)
    name = VNI_TYPES[type].titleize + " mới"
  end
end
