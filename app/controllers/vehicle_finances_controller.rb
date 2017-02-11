class VehicleFinancesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_vehicle_finance, only: [:update, :destroy]
  before_action :authenticate_account!
  require 'will_paginate/array'

  def index
    @vehicle_finance = VehicleFinance.new
    @vehicle_finances = get_vehicle_finances

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data VehicleFinance.all.to_csv }
      format.xls {
        filename = "VehicleFinance-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        send_data(VehicleFinance.all.order(:id).to_xls(:only => VehicleFinance::HEADER_COLUMNS,
          :header_columns => VehicleFinance::HEADERS),
          type: "text/xls; charset=utf-8; header=present",
          filename: filename
        )
      }
      format.json { render json: @vehicle_finances }
    end
  end

  def create
    @vehicle_finance = VehicleFinance.new(vehicle_finance_params)
    @vehicle_finance.started_time = Date.strptime(params[:started_time], "%m/%Y") if params[:started_time] != ''

    if @vehicle_finance.ground_id.present? && @vehicle_finance.started_time.present?
      vehicle_finance_check = VehicleFinance.where("ground_id = #{@vehicle_finance.ground_id} " +
          " AND extract(month from started_time) = #{@vehicle_finance.started_time.month} " +
          " AND extract(year from started_time) = #{@vehicle_finance.started_time.year}")
      if vehicle_finance_check.present?
        @vehicle_finance.errors.add(:started_time, :not_specified, message: "Đã tồn tại số nước của mặt bằng này trong tháng #{@vehicle_finance.started_time.month}")
      end
    end

    respond_to do |format|
      begin
        if vehicle_finance_check.blank? && @vehicle_finance.save
          flash.now[:success] = "Thêm phí thẻ xe thành công"
          History.log(current_account, "Tạo phí thẻ xe #{@vehicle_finance.id}")
          format.html { redirect_to vehicle_finances_path }
          format.js {
            @vehicle_finances = get_vehicle_finances
            render :index, status: :created, location: @vehicle_finance
          }
        else
          format.js { render json: @vehicle_finance.errors, status: :unprocessable_entity }
        end
      rescue Exception => msg
        flash[:danger] = "#{msg}";
        format.js { render :error_messages }
      end
    end
  end

  def update
    @vehicle_finance.attributes = vehicle_finance_params
    changes = @vehicle_finance.changes

    respond_to do |format|
      if @vehicle_finance.save
        flash[:success] = "Cập nhật phí thẻ xe thành công"
        History.log(current_account, "Sửa phí thẻ xe #{@vehicle_finance.id}", changes, VehicleFinance::VNI_COLUMNS)
        format.html { redirect_to vehicle_finances_path }
        format.js { render :js => "window.location.replace('#{vehicle_finances_path}');" }
      else
        format.js { render json: @vehicle_finance.errors, status: :unprocessable_entity }
      end
    end
  end

  def pay
    @vehicle_finance = VehicleFinance.find(params['ground_id'])
    @money_error = ''
    @money = params[:given_money].to_i
    if !is_integer(params[:given_money]) || @money == 0
      @money_error = "Số tiền không hợp lệ"
    elsif @money < @vehicle_finance.remain
      @money_error = "Thanh toán chưa đủ"
    else
      # pay for vehicle_finance
      @vehicle_finance.pay(@money)
      InforVehicleJob.perform_in(30, @vehicle_finance, Apartment::Tenant.current)
    end

    respond_to do |format|
      if @money_error.present?
        format.js { render 'pay_failed' }
      else
        format.js {
          flash[:success] = "Thanh toán tiền giữ xe cho #{@vehicle_finance.ground_name} " +
                              "tháng #{@vehicle_finance.started_time.month} thành công. Vui lòng check mail"
          History.log(current_account, "Thanh toán phí giữ xe #{@vehicle_finance.id}")
          render :js => "window.location.replace('#{vehicle_finances_path}');"
        }
      end
    end
  end

  def destroy
    @vehicle_finance.update_attribute(:is_current, true)
    flash[:success] = "Phí thẻ xe '#{@vehicle_finance.license_no}' của mặt bằng #{@vehicle_finance.ground_name} đã tạm ngưng"
    History.log(current_account, "Ngừng phí thẻ xe của #{@vehicle_finance.id}")
    redirect_to vehicle_finances_path
  end

  private
    def set_vehicle_finance
      @vehicle_finance = VehicleFinance.find(params[:id])
    end

    def vehicle_finance_params
      params.require(:vehicle_finance).permit(:vehicle_card_id, :debt, :paid)
    end

    def get_vehicle_finances
      vehicle_finances = VehicleFinance.search(params[:search])
      if params[:filter_date].present?
        # filter_date format: m/yyyy
        fd = params[:filter_date].split("/")
        if fd.present? && fd.size == 2
          vehicle_finances = vehicle_finances.where('extract(month from started_time) = ? AND extract(year from started_time) = ?', fd[0], fd[1])
        end
      elsif params[:type] == "active" || !params[:type]
        vehicle_finances = vehicle_finances.where(:is_current => true)
      elsif params[:type] == "deactive"
        vehicle_finances = vehicle_finances.where(:is_current => false)
      end

      if sort_column == 'ground_id'
        vehicle_finances = vehicle_finances.sort_by(&:ground_name)
        vehicle_finances = vehicle_finances.reverse if params[:direction] == 'desc'
      elsif sort_column == 'vehicle_card_id'
        vehicle_finances = vehicle_finances.sort_by(&:card_no)
        vehicle_finances = vehicle_finances.reverse if params[:direction] == 'desc'
      else
        vehicle_finances = vehicle_finances.order(sort_column + " " + sort_direction)
      end
      return vehicle_finances.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      VehicleFinance.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
