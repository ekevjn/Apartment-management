class SetbuildingController < ApplicationController
  before_action :authenticate_account!

  def index
    @building = Building.new
  end

  def create
    @building = Building.new(building_params)
    respond_to do |format|
      if @building.save
        History.log(current_account, "Tạo tòa nhà #{@building.name}")
        format.html { redirect_to buildings_path }
        format.js {
          @ground = Ground.new
          @ground.building_id = @building.id
          render :step1done, status: :created, location: @building
        }
      else
        format.js { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  def buildingchoice
    respond_to do |format|
      if params[:buildingchoice].present?
        format.js {
          @ground = Ground.new
          @ground.building_id = params[:buildingchoice]
          render :step1done, status: :created, location: @building
        }
      else
        format.js { render 'error_choose' }
      end
    end
  end

  def createground
    @ground = Ground.new(ground_params)
    respond_to do |format|
      if @ground.save
        History.log(current_account, "Tạo mặt bằng #{@ground.name}")
        format.html { redirect_to citizens_path }
        format.js {
          @citizen = Citizen.new
          @citizen.ground_id = @ground.id
          render :step2done, status: :created, location: @ground
        }
      else
        format.js { render json: @ground.errors, status: :unprocessable_entity }
      end
    end
  end

  def createcitizen
    @citizen = Citizen.new(citizen_params)
    @citizen.dob = Date.strptime(params[:dob], "%d/%m/%Y") if params[:dob] != ''
    respond_to do |format|
      if @citizen.save
        History.log(current_account, "Tạo cư dân #{@citizen.name}")
        format.html { redirect_to citizens_path }
        format.js {
          render :step3done, status: :created, location: @citizen
        }
      else
        format.js { render json: @citizen.errors, status: :unprocessable_entity }
      end
    end
  end

  def export
    respond_to do |format|
      hash = Hash[[Building::HEADERS_TEMPLATE,Building::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-toa-nha.xls")
      }
    end
  end

  def import
    if params[:file].present?
      begin
        count = Building.import(params[:file])
        flash.now[:success] = "Nhập dữ liệu tòa nhà từ file excel thành công, thêm #{count} tòa nhà"
        History.log(current_account, "Import thêm #{count} tòa nhà")
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

  def liabilities
    if params[:building_id].blank?
      flash.now[:danger] = 'Hãy chọn tòa nhà trước khi thực hiện'
    elsif params[:started_time].blank?
      flash.now[:danger] = 'Hãy chọn tháng bắt đầu trước khi thực hiện'
    elsif params[:end_time].blank?
      flash.now[:danger] = 'Hãy chọn tháng kết thúc trước khi thực hiện'
    else
      # @grounds = Ground.where(:id => params[:building_id])
      @building_id = params[:building_id]
      @started_time_report = params[:started_time]
      @end_time_report = params[:end_time]

      params[:started_time] = Date.strptime(params[:started_time], "%m/%Y").change(:day => 1)
      params[:end_time] = Date.strptime(params[:end_time], "%m/%Y").end_of_month

      if params[:started_time] >= Date.today.end_of_month
        flash.now[:danger] = 'Tháng bắt đầu phải nhỏ hơn tháng hiện tại'
      elsif params[:started_time] > params[:end_time]
        flash.now[:danger] = 'Tháng kết thúc phải lớn hơn hoặc bằng tháng bắt đầu '
      else
        # waters = Water.where("ground_id in (?) AND .... ", @ground.map(&:id), )
        @debt_water = Water.joins(:ground).where('grounds.building_id = ?
          AND waters.started_time >= ? AND waters.started_time <= ?',
          params[:building_id], params[:started_time], params[:end_time]).sum(:debt)
        @paid_water = Water.joins(:ground).where('grounds.building_id = ?
          AND waters.started_time >= ? AND waters.started_time <= ?',
          params[:building_id], params[:started_time], params[:end_time]).sum(:paid)
        @fee_water = Water.joins(:ground).where('grounds.building_id = ?
          AND waters.started_time >= ? AND waters.started_time <= ?',
          params[:building_id], params[:started_time], params[:end_time]).sum(:fee)

        @debt_service = Service.joins(:ground).where('grounds.building_id = ?
          AND services.started_time >= ? AND services.started_time <= ?',
          params[:building_id], params[:started_time], params[:end_time]).sum(:debt)
        @paid_service = Service.joins(:ground).where('grounds.building_id = ?
          AND services.started_time >= ? AND services.started_time <= ?',
          params[:building_id], params[:started_time], params[:end_time]).sum(:paid)
        @fee_service = Service.joins(:ground).where('grounds.building_id = ?
          AND services.started_time >= ? AND services.started_time <= ?',
          params[:building_id], params[:started_time], params[:end_time]).sum(:fee)

        @debt_vehicle = VehicleFinance.joins(:ground).where('grounds.building_id = ?
          AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
          params[:building_id], params[:started_time], params[:end_time]).sum(:debt)
        @paid_vehicle = VehicleFinance.joins(:ground).where('grounds.building_id = ?
          AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
          params[:building_id], params[:started_time], params[:end_time]).sum(:paid)
        @fee_vehicle = VehicleFinance.joins(:ground).where('grounds.building_id = ?
          AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
          params[:building_id], params[:started_time], params[:end_time]).sum(:fee)

        @debt = @debt_water + @debt_service + @debt_vehicle
        @paid = @paid_water + @paid_service + @paid_vehicle
        @fee = @fee_water + @fee_service + @fee_vehicle
      end
    end

    respond_to do |format|
      if flash.now[:danger].blank?
        format.js { render :createchart }
      else
        format.js { render :layout_messages }
      end
    end
  end

  private
    def building_params
      params.require(:building).permit(:name, :num_floors)
    end

    def ground_params
      params.require(:ground).permit(:name, :area_length, :area_width,
        :kind, :floor, :building_id, :num_rooms)
    end

    def citizen_params
      params.require(:citizen).permit(:name, :ground_id, :government_id,
        :phone, :email, :gender, :hometown, :dob, :nationality, :is_water_deal)
    end
end
