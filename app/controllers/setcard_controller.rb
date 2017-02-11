class SetcardController < ApplicationController
  include GroundsHelper
  before_action :authenticate_account!

  def index
  end

  def create_vehicle_card
    @vehicle_card = VehicleCard.new(vehicle_card_params)
    @vehicle_card.registered_time = Date.strptime(params[:registered_time], "%d/%m/%Y") if params[:registered_time].present?
    @vehicle_card.started_time = Date.strptime(params[:started_time], "%m/%Y") if params[:started_time].present?
    @vehicle_card.outdate_time = Date.strptime(params[:outdate_time], "%m/%Y") if params[:outdate_time].present?

    respond_to do |format|
      if @vehicle_card.save
        History.log(current_account, "Tạo thẻ xe #{@vehicle_card.id} của mặt bằng #{@vehicle_card.ground_name}")
        format.js { render :vehicle_card_success, status: :created }
      else
        puts @vehicle_card.errors.to_hash
        format.js { render json: @vehicle_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_vehicle_card
    respond_to do |format|
      hash = Hash[[VehicleCard::HEADERS_TEMPLATE,VehicleCard::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-the-xe.xls")
      }
    end
  end

  def import_vehicle_card
    if params[:file].present?
      begin
        count = VehicleCard.import(params[:file])
        flash.now[:success] = "Nhập dữ liệu thẻ xe từ file excel thành công, thêm #{count} thẻ xe"
        History.log(current_account, "Import thêm #{count} thẻ xe")
      rescue Exception => msg
        flash.now[:danger] = "#{msg}. Không thêm dữ liệu nào"
      end
    else
      flash.now[:danger] = "Vui lòng nhập file Excel"
    end
    respond_to do |format|
      format.js { render :layout_messages }
    end
  end

  def open_vehicle_card
    respond_to do |format|
      if params["ground_id"].present?
        @vehicle_cards = VehicleCard.where(:ground_id => params["ground_id"])
        format.js { render :open_vehicle_card }
      else
        flash.now[:danger] = 'Hãy chọn mặt bằng'
        format.js { render :layout_messages }
      end
    end
  end

  def open_service
    @vehicle_card = VehicleCard.find(params[:id])

    respond_to do |format|
      if @vehicle_card.ground.owner_id.blank?
        format.js { render :open_service_failed }
      else
        open_vehicle_finance(@vehicle_card)
        History.log(current_account, "Mở dịch vụ thẻ xe #{@vehicle_card.card_no} tháng #{Date.today.month}")
        @vehicle_cards = VehicleCard.where(:ground_id => @vehicle_card.ground_id)
        format.js { render :open_service_success }
      end
    end
  end

  def close_vehicle_card
    respond_to do |format|
      if params["ground_id"].present?
        @vehicle_cards = VehicleCard.where(:ground_id => params["ground_id"])
        format.js { render :close_vehicle_card }
      else
        flash.now[:danger] = 'Hãy chọn mặt bằng'
        format.js { render :layout_messages }
      end
    end
  end

  def close_service
    @vehicle_card = VehicleCard.find(params[:id])
    respond_to do |format|
      if exist_vehicle_finances?(@vehicle_card)
        @vehicle_finance = current_finance_by_card(@vehicle_card)
        format.js { render :close_service_failed }
      else
        if params[:type] == 'lost'
          @vehicle_card.update(:status => VehicleCard::STATUS_LOST)
          History.log(current_account, "khai báo mất thẻ xe #{@vehicle_card.card_no}")
        elsif params[:type] == 'lock'
          @vehicle_card.update(:status => VehicleCard::STATUS_LOCK)
          History.log(current_account, "Khóa thẻ xe #{@vehicle_card.card_no}")
        else
          @vehicle_card.update(:status => VehicleCard::STATUS_CREATED)
          History.log(current_account, "Đóng dịch vụ thẻ xe #{@vehicle_card.card_no} tháng #{Date.today.month}")
        end
        format.js { render :close_service_success }
      end
    end
  end

  def payout
    begin
      @vehicle_finance = VehicleFinance.find_by(:id => params[:vehicle_finance_id])
      @vehicle_finance.payout
      InforVehicleJob.perform_in(30, @vehicle_finance, Apartment::Tenant.current)
      History.log(current_account, "Thanh toán phí xe cho #{@vehicle_finance.id} tháng #{@vehicle_finance.started_time.month}")
    rescue Exception => msg
      @exception_messages = "#{msg}";
    end

    respond_to do |format|
      if @exception_messages.present?
        format.js { render :payout_failed }
      else
        ground = @vehicle_finance.vehicle_card.ground
        if !exist_finances?(ground)
          ground.update(:status => Ground::STATUS_BOUGHT)
        end
        History.log(current_account, "Đóng dịch vụ #{ground.name}")
        format.js { render :payout_success }
      end
    end
  end

  private
    def vehicle_card_params
      params.require(:vehicle_card).permit(:card_no, :vehicle_type, :ground_id,
                     :citizen_id, :started_time, :created_fee, :outdate_time,
                     :registered_time, :license_no, :description)
    end
end
