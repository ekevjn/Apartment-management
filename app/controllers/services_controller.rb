class ServicesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_service, only: [:update, :destroy]
  before_action :authenticate_account!
  require 'will_paginate/array'

  def index
    @service = Service.new
    @services = get_services

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data Service.all.to_csv }
      format.xls {
        filename = "Service-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        send_data(Service.all.order(:id).to_xls(:only => Service::HEADER_COLUMNS,
          :header_columns => Service::HEADERS),
          type: "text/xls; charset=utf-8; header=present",
          filename: filename
        )
      }
      format.json { render json: @services }
    end
  end

  def create
    @service = Service.new(service_params)
    @service.started_time = Date.strptime(params[:started_time], "%m/%Y") if params[:started_time].present?

    if @service.ground_id.present? && @service.started_time.present?
      service_check = Service.where("ground_id = #{@service.ground_id} " +
          " AND extract(month from started_time) = #{@service.started_time.month} " +
          " AND extract(year from started_time) = #{@service.started_time.year}")
      if service_check.present?
        @service.errors.add(:started_time, :not_specified, message: "Đã tồn tại phí chung của mặt bằng này trong tháng #{@service.started_time.month}")
      end
    end

    respond_to do |format|
      if service_check.blank? && @service.save
        flash.now[:success] = "Thêm phí chung thành công"
        History.log(current_account, "Tạo phí chung cho #{@service.ground_name}")
        format.js {
          @services = get_services
          render :index, status: :created, location: @service
        }
      else
        format.js { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @service.attributes = service_params
    changes = @service.changes

    respond_to do |format|
      if @service.save
        flash.now[:success] = "Cập nhật phí chung thành công"
        History.log(current_account, "Sửa phí chung #{@service.ground_name}", changes, Service::VNI_COLUMNS)
        format.js { render :js => "window.location.replace('#{services_path}');" }
      else
        format.js { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def pay
    @service = Service.find(params['ground_id'])
    @money_error = ''
    @money = params[:given_money].to_i
    if !is_integer(params[:given_money]) || @money == 0
      @money_error = "Số tiền không hợp lệ"
    elsif @money < @service.remain
      @money_error = "Thanh toán chưa đủ"
    else
      # pay for service
      @service.pay(@money)
      InforServiceJob.perform_in(30, @service, Apartment::Tenant.current)
    end

    respond_to do |format|
      if @money_error.present?
        format.js { render 'pay_failed' }
      else
        format.js {
          flash[:success] = "Thanh toán phí chung cho #{@service.ground_name} thành công."+
                                " Vui lòng check mail"
          History.log(current_account, "Thanh toán phí chung cho #{@service.ground_name} tháng #{@service.started_time}")
          render :js => "window.location.replace('#{services_path}');"
        }
      end
    end
  end

  def destroy
    @service.update_attribute(:is_current, false)
    flash[:success] = "Dịch vụ của #{@service.ground_name} tạm ngưng"
    History.log(current_account, "Ngừng phí chung của #{@service.ground_name}")
    redirect_to services_path
  end

  private
    def set_service
      @service = Service.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:ground_id, :debt, :paid)
    end

    def get_services
      services = Service.search(params[:search])
      if params[:filter_date].present?
        # filter_date format: m/yyyy
        fd = params[:filter_date].split("/")
        if fd.present? && fd.size == 2
          services = services.where('extract(month from started_time) = ? AND extract(year from started_time) = ?', fd[0], fd[1])
        end
      elsif params[:type] == "active" || !params[:type]
        services = services.where(:is_current => true)
      elsif params[:type] == "deactive"
        services = services.where(:is_current => false)
      end

      if sort_column == 'ground_id'
        services = services.sort_by(&:ground_name)
        services = services.reverse if params[:direction] == 'desc'
      else
        services = services.order(sort_column + " " + sort_direction)
      end
      return services.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      Service.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
