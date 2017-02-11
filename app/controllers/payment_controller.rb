class PaymentController < ApplicationController
  before_action :authenticate_account!

  def index
    @ground = Ground.new
  end

  def choose_pay
    @ground_id = params[:ground_id]
    count = 0
    if @ground_id.present?
      @pay_fee = 0
      if params[:service_checkbox].present?
        services = Service.where(:ground_id => @ground_id, :is_current => true)
        if services.present? &&
            services.first.started_time.month == Date.today.month &&
              services.first.started_time.year == Date.today.year
          @service = services.first
          @pay_fee += @service.remain
        end
        count += 1
      end
      if params[:water_checkbox].present?
        waters = Water.where(:ground_id => @ground_id, :is_current => true)
        if waters.present? &&
            waters.first.started_time.month == Date.today.month &&
              waters.first.started_time.year == Date.today.year
          @water = waters.first
          @pay_fee += @water.remain
        end
        count += 1
      end
      if params[:vehicle_checkbox].present?
        @vehicle_finances = VehicleFinance.where("ground_id = #{@ground_id} " +
                " AND is_current = true " +
                " AND extract(month from started_time) = #{Date.today.month} " +
                " AND extract(year from started_time) = #{Date.today.year}")
        if @vehicle_finances.present?
          @vehicle_finances.each do |vehicle_finance|
            @pay_fee += vehicle_finance.remain
          end
        end
        count += 1
      end
    end

    respond_to do |format|
      format.js {
        if count > 0
          render :step1done
        else
          render :step1nomethod
        end
      }
    end
  end

  def pay
    @pay_type = []
    @ground_id = params[:ground_id]
    @ground_name = Ground.find_by(:id => params[:ground_id]).name
    begin
      ActiveRecord::Base.transaction do
        # pay for service
        if params[:service_id].present?
          @service = Service.find(params[:service_id])
          @service.pay_enough
          History.log(current_account, "Thanh toán phí chung cho #{@service.ground_name} tháng #{@service.started_time}")
          @pay_type.push("service")
        end
        # pay for water
        if params[:water_id].present?
          @water = Water.find(params[:water_id])
          @water.pay_enough
          History.log(current_account, "Thanh toán phí nước cho #{@water.ground_name} tháng #{@water.started_time}")
          @pay_type.push("water")
        end
        # pay for vehicle finance
        if params[:vehicle_finance_id].present?
          @vehicle_finances = VehicleFinance.where("ground_id = #{@ground_id} " +
                  " AND is_current = true " +
                  " AND extract(month from started_time) = #{Date.today.month} " +
                  " AND extract(year from started_time) = #{Date.today.year}")
          if @vehicle_finances.present?
            @vehicle_finances.each do |vehicle_finance|
              @vehicle_finances_ids = @vehicle_finances.map(&:id).join('-')
              vehicle_finance.pay_enough
              History.log(current_account, "Thanh toán phí xe cho #{vehicle_finance.id} tháng #{vehicle_finance.started_time}")
            end
            @pay_type.push("vehicle_finance")
          end
        end
      end

      # send email
      if @service.present?
        InforServiceJob.perform_in(30, @service, Apartment::Tenant.current)
      end
      if @water.present?
        InforWaterJob.perform_in(30, @water, Apartment::Tenant.current)
      end
      if @vehicle_finances.present?
        @vehicle_finances.each do |vehicle_finance|
          InforVehicleJob.perform_in(30, vehicle_finance, Apartment::Tenant.current)
        end
      end
    rescue Exception => msg
      @error_messages = "#{msg}";
    end

    respond_to do |format|
      if @error_messages.present?
        format.js { render :step2failed }
      else
        format.js { render :step2done }
      end
    end
  end

  def input_water
    @water = Water.find_by(:ground_id => params[:ground_id], :is_current => true)
    water_num_old = @water.water_num
    @water.water_num = (params[:water_no].to_i - @water.water_no) + water_num_old
    @water.water_no = params[:water_no]
    respond_to do |format|
      changes = @water.changes
      begin
        if @water.save
          History.log(current_account, "Sửa phí nước #{@water.ground_name}", changes, Water::VNI_COLUMNS)
        else
          @error_messages = "Chỉ số nước không hợp lệ vì nhỏ hơn tháng trước"
        end
      rescue Exception => msg
        @error_messages = "#{msg}";
      end
      if @error_messages.blank?
        format.js { render :inputsuccess }
      else
        format.js { render :inputerror }
      end
    end
  end

  def export_water
    respond_to do |format|
      hash = Hash[[Water::HEADERS_TEMPLATE,Water::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "water-num-template.xls")
      }
    end
  end

  def import_water
    if params[:file].present?
      begin
        count = Water.import(params[:file])
        flash.now[:success] = "Nhập dữ liệu khối nước từ file excel thành công, cập nhật khối nước ở #{count} mặt bằng"
        History.log(current_account, "cập nhật khối nước ở #{count} mặt bằng bằng excel")
      rescue Exception => msg
        flash.now[:danger] = "#{msg}. Không cập nhật dữ liệu nào"
      end
    else
      flash[:danger] = "Vui lòng nhập file Excel"
    end
    respond_to do |format|
      format.js { render :import_messages }
    end
  end

  def close_finances
    begin
      if close_all_finances(Date.today.last_month.month, Date.today.last_month.year)
        flash[:success] = "Chốt sổ thành công"
        History.log(current_account, "Chốt sổ tháng #{Date.today.strftime("%m/%Y")}")
      else
        flash[:warning] = "Bạn đã chốt sổ tháng này"
      end
    rescue Exception => msg
      flash[:danger] = "#{msg}";
    end
    redirect_to payment_index_path
  end
end
