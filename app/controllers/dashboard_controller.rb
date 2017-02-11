class DashboardController < ApplicationController
  before_action :authenticate_account!

  def index
    @waters = Water.all
  end

  def map_ground
    respond_to do |format|
      if params[:building_id].present?
        @grounds = Ground.where(:building_id => params[:building_id], :del_flg => 0).order(:floor, :name)
        @num_floors = Building.find_by_id(params[:building_id]).num_floors
        @building_id =  params[:building_id];
        format.js { render :map_ground }
      else
        flash.now[:danger] = "Hãy chọn 1 tòa nhà trước khi thực hiện"
        format.js { render :error_messages }
      end
    end
  end

  def show_ground
    @ground = Ground.find_by_id(params[:ground_id])
    respond_to do |format|
      if @ground.present?
        format.js { render :show_ground }
      else
        flash.now[:danger] = "Hãy chọn 1 mặt bằng trước khi thực hiện"
        format.js { render :error_messages }
      end
    end
  end

  def create_chart
    # validate input
    if params[:table_id].blank?
      flash.now[:danger] = 'Vui lòng chọn đối tượng để thực hiện'
    elsif params[:chart_id].blank?
      flash.now[:danger] = 'Vui lòng chọn biểu đồ để thực hiện'
    elsif params[:kind_id].blank?
      flash.now[:danger] = 'Vui lòng chọn loại để thực hiện'
    elsif params[:group_by_id].blank?
      flash.now[:danger] = 'Vui lòng chọn kiểu nhóm để thực hiện'
    elsif params[:started_time].blank?
      flash.now[:danger] = 'Vui lòng chọn tháng bắt đầu để thực hiện'
    elsif params[:end_time].blank?
      flash.now[:danger] = 'Vui lòng chọn tháng kết thúc để thực hiện'
    elsif params[:group_date_id].blank?
      flash.now[:danger] = 'Vui lòng chọn đơn vị để thực hiện'
    else
      @chart_type = params[:chart_id]
      started_time = Date.strptime(params[:started_time], "%m/%Y").change(:day => 1)
      end_time = Date.strptime(params[:end_time], "%m/%Y").end_of_month

      if started_time >= Date.today.end_of_month
        flash.now[:danger] = 'Tháng bắt đầu phải nhỏ hơn tháng hiện tại'
      elsif started_time > end_time
        flash.now[:danger] = 'Tháng kết thúc phải lớn hơn hoặc bằng tháng bắt đầu '
      elsif params[:table_id] == 'Water'
        @objects = Water.where('waters.started_time >= ? AND waters.started_time <= ?',
          started_time, end_time)
      elsif params[:table_id] == 'Service'
        @objects = Service.where('services.started_time >= ? AND services.started_time <= ?',
          started_time, end_time)
      elsif params[:table_id] == 'VehicleCard'
        @objects = VehicleFinance.where('vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
          started_time, end_time)
      end
    end

    if @objects.present?
      if params[:kind_id] != "must_pay"
        @objects = @objects.send(params[:group_date_id], "started_time", { format: "%b %Y" }).send(params[:group_by_id], params[:kind_id])
      else
        @objects = @objects.send(params[:group_date_id], "started_time", { format: "%b %Y" }).send(params[:group_by_id], "debt + fee - paid")
      end
    end

    respond_to do |format|
      if flash.now[:danger].blank?
        format.js { render :create_chart }
      else
        format.js { render :error_messages }
      end
    end
  end
end

