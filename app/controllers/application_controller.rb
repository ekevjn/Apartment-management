class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :validate_subdomain
  before_action :check_payment_date
  before_action :check_first_time

  protect_from_forgery with: :exception
  include ApplicationHelper
  include AdminSessionsHelper

  def validate_subdomain
    if request.subdomain.present? && request.subdomain != 'www'
      tower = Tower.find_by_subdomain(request.subdomain)
      if tower.del_flg == 1
        redirect_to sub_err_url(subdomain: 'www')
      end
    end
  end

  def check_payment_date
    if request.subdomain.present? && request.subdomain != 'www' &&
        request.original_fullpath != "/" && !request.original_fullpath.starts_with?('/payment') &&
          !request.original_fullpath.starts_with?('/accounts')
      if type_of_payment_day_close == ApplicationHelper::FINANCES_CLOSING
        flash[:warning] = "Gần tới ngày chốt sổ vui lòng vào 'Thanh toán' để chốt sổ"
      elsif type_of_payment_day_close == ApplicationHelper::FINANCES_NOT_CLOSE
        flash[:danger] = "Bạn vẫn chưa chốt sổ tháng #{Date.today.last_month.month}. Vui lòng chốt sổ trước khi thực hiện thao tác khác"
        redirect_to payment_index_path
      end
    end
  end

  def check_first_time
    if request.subdomain.present? && request.subdomain != 'www' &&
        request.original_fullpath != "/" && !request.original_fullpath.starts_with?('/first_times') &&
          !request.original_fullpath.starts_with?('/accounts')
      if Building.all.blank?
        #flash[:warning] = "Có thể đây là lần đầu đăng nhập của bạn, bạn cần thiết lập cho chung cư của bạn trước khi sử dụng"
        redirect_to first_times_path
      end
    end
  end

  def switch_tenant(name)
    Apartment::Tenant.switch!(name)
  end

  def switch_root_tenant
    Apartment::Tenant.switch!
  end
end
