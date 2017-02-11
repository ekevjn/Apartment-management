class SetgroundController < ApplicationController
  include GroundsHelper
  before_action :authenticate_account!

  def index
    @ground = Ground.new
    @groundhistory = GroundHistory.paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html {}
      format.js { render :index }
    end
  end

  def create
    @ground = Ground.new(ground_params)
    respond_to do |format|
      if @ground.save
        History.log(current_account, "Tạo mặt bằng #{@ground.name}")
        format.js { render :groundsuccess }
      else
        format.js { render json: @ground.errors, status: :unprocessable_entity }
      end
    end
  end

  def export
    respond_to do |format|
      hash = Hash[[Ground::HEADERS_TEMPLATE,Ground::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-mat-bang.xls")
      }
    end
  end

  def import
    if params[:file].present?
      begin
        count = Ground.import(params[:file])
        flash.now[:success] = "Nhập dữ liệu mặt bằng từ file excel thành công, thêm #{count} mặt bằng"
        History.log(current_account, "Import thêm #{count} mặt bằng")
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

  def export_owner
    respond_to do |format|
      hash = Hash[[Ground::HEADERS_TEMPLATE_OWNER,Ground::HEADERS_TEMPLATE_OWNER].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-chu-ho.xls")
      }
    end
  end

  def import_owner
    if params[:file].present?
      begin
        count = Ground.import_owner(params[:file])
        flash.now[:success] = "Nhập dữ liệu chủ hộ từ file excel thành công, cập nhật #{count} chủ hộ"
        History.log(current_account, "Cập nhật thêm #{count} chủ hộ từ excel")
      rescue Exception => msg
        flash.now[:danger] = "#{msg}. Không cập nhật dữ liệu nào"
      end
    else
      flash.now[:danger] = "Vui lòng nhập file Excel"
    end
    respond_to do |format|
      format.js { render :layout_messages }
    end
  end

  def ground_owner
    if params[:ground_id].blank?
      flash.now[:danger] = 'Hãy chọn một căn hộ'
    elsif params[:owner_id].blank?
      flash.now[:danger] = 'Hãy chọn một chủ hộ'
    else
      check_ground_owner = Ground.find_by(:owner_id => params[:owner_id])
      if check_ground_owner.present?
        # citizen la chu ho cua phong khac
        flash.now[:danger] = "#{params[:owner_name_search]} đang là chủ hộ của #{check_ground_owner.name}. " +
        "Nếu muốn đổi chủ hộ thì cư dân này phải rời khỏi phòng #{check_ground_owner.name}"
      else
        @ground = Ground.find(params[:ground_id])
        @new_owner = Citizen.find(params[:owner_id])
        if @ground.status == Ground::STATUS_EMPTY
          # neu mat bang con trong ( chua co chu ho )
          @ground.owner_id = @new_owner.id
          @ground.num_citizens += 1
          @ground.num_water_deal += 1 if @new_owner.is_water_deal
          @ground.save!
          flash.now[:success] = "Đã thay đổi chủ hộ của mặt bằng #{@ground.name} là #{@new_owner.name}"
        else
          if exist_finances?(@ground)
            flash.now[:danger] = "Mặt bằng này chưa thanh toán xong các dịch vụ. " +
            "Vui lòng thanh toán theo bên dưới trưóc khi đổi chủ hộ"
            close = true
            # =================================
            # ====== get current finances =====
            @pay_fee = 0
            @ground_id = @ground.id
            @service = current_service(@ground)
            @water = current_water(@ground)
            @vehicle_finances = current_vehicle_finances(@ground)
            if @service.present?
              @pay_fee += @service.remain
            end
            if @water.present?
              @pay_fee += @water.remain
            end
            if @vehicle_finances.present?
              @vehicle_finances.each do |vehicle_finance|
                @pay_fee += vehicle_finance.remain
              end
            end
            # =================================
          else
            # co chu ho va da thanh toan xong
            # chu ho cu roi di
            ActiveRecord::Base.transaction do
              old_owner = Citizen.find(@ground.owner_id)
              old_owner.ground_id = nil
              old_owner.save!

              # chu ho moi den
              @ground.owner_id = @new_owner.id
              @ground.save!
              flash.now[:success] = "Đã thay đổi chủ hộ của mặt bằng #{@ground.name} là #{@new_owner.name}"
            end
          end
        end
      end
    end

    respond_to do |format|
      if close.present?
        format.js { render :serviceclose }
      elsif flash.now[:danger].present?
        format.js { render :layout_messages }
      else
        @groundhistory = GroundHistory.paginate(:page => params[:page], :per_page => 10)
        format.js { render :ownersuccess }
      end
    end
  end

  def create_owner
    @citizen = Citizen.new(citizen_params)
    @citizen.dob = Date.strptime(params[:dob], "%d/%m/%Y") if params[:dob] != ''

    respond_to do |format|
      if @citizen.save
        History.log(current_account, "Tạo cư dân #{@citizen.name}")
        format.js { render :create_owner }
      else
        format.js { render json: @citizen.errors, status: :unprocessable_entity }
      end
    end
  end

  def ground_service
    @ground = Ground.find_by(:id => params[:id])
    if params[:id].blank?
      flash.now[:danger] = 'Hãy chọn một căn hộ'
    elsif params[:status].blank?
      flash.now[:danger] = 'Hãy chọn Mở hoặc Đóng dịch vụ'
    elsif @ground.status == Ground::STATUS_EMPTY
      flash.now[:danger] = 'Mặt bằng này đang còn trống không thể mở - đóng dịch vụ. Hãy thêm chủ hộ cho mặt bằng'
      # chọn đóng dịch vụ
    elsif params[:status] == 'close-services'
      if @ground.status == Ground::STATUS_BOUGHT
        flash.now[:danger] = 'Mặt bằng này đã đóng dịch vụ rồi'
      elsif exist_finances?(@ground)
        flash.now[:danger] = 'Mặt bằng này chưa thanh toán xong các dịch vụ. Không thể đóng dịch vụ vui lòng thanh toán theo bên dưới'
        close = true
        # =================================
        # ====== get current finances =====
        @pay_fee = 0
        @ground_id = @ground.id
        @service = current_service(@ground)
        @water = current_water(@ground)
        @vehicle_finances = current_vehicle_finances(@ground)
        if @service.present?
          @pay_fee += @service.remain
        end
        if @water.present?
          @pay_fee += @water.remain
        end
        if @vehicle_finances.present?
          @vehicle_finances.each do |vehicle_finance|
            @pay_fee += vehicle_finance.remain
          end
        end
        # =================================
      else
        # đóng dịch vụ
        @success_content = 'Đóng dịch vụ thành công'
        close_service(@ground)
        History.log(current_account, "Đóng dịch vụ #{@ground.name}")
      end
    else
      # chọn mở dịch vụ
      if @ground.status == Ground::STATUS_USED
        flash.now[:danger] = 'Mặt bằng này đã mở dịch vụ rồi'
      else
        # mớ dịch vụ
        @success_content = 'Mở dịch vụ thành công'
        open_service(@ground)
        History.log(current_account, "Mở dịch vụ #{@ground.name}")
      end
    end

    respond_to do |format|
      if close.present?
        format.js { render :serviceclose }
      elsif flash.now[:danger].present?
        format.js { render :layout_messages }
      else
        @groundhistory = GroundHistory.paginate(:page => params[:page], :per_page => 10)
        format.js { render :servicesuccess }
      end
    end
  end

  def leave_ground
    @citizen = Citizen.find_by(:id => params[:citizen_id])
    if params[:citizen_id].blank?
      flash.now[:danger] = 'Hãy chọn cư dân'
    elsif @citizen.ground_id.blank?
      flash.now[:danger] = 'Cư dân này không ở mặt bằng nào cả. Không thể rời đi'
    elsif @citizen.ground.owner_id != @citizen.id
      # khong phai la chu ho
      @citizen.ground.num_citizens -= 1
      @citizen.ground.num_water_deal -= 1 if @citizen.is_water_deal
      @citizen.ground.save!
      @citizen.ground_id = nil
      @citizen.save!
    elsif @citizen.ground.num_citizens > 1
      # la chu ho va ton tai 1 cu dan khac
      flash.now[:danger] = "Mặt bằng này còn có cư dân khác. Bạn phải đổi chủ hộ của mặt bằng trước khi rời đi"
    elsif exist_finances?(@citizen.ground)
      # la chu ho chua thanh toan
      flash.now[:danger] = 'Mặt bằng này chưa thanh toán xong các dịch vụ. Vui lòng thanh toán theo bên dưới trước khi rời khỏi'
      close = true
      @ground = @citizen.ground
      # =================================
      # ====== get current finances =====
      @pay_fee = 0
      @ground_id = @ground.id
      @service = current_service(@ground)
      @water = current_water(@ground)
      @vehicle_finances = current_vehicle_finances(@ground)
      @pay_fee += @service.remain if @service.present?
      @pay_fee += @water.remain if @water.present?
      if @vehicle_finances.present?
        @vehicle_finances.each do |vehicle_finance|
          @pay_fee += vehicle_finance.remain
        end
      end
      # =================================
    else
      # la chu ho da thanh toan
      # doi voi chu ho cu
      ground = @citizen.ground
      @citizen.ground_id = nil
      @citizen.save!

      # doi voi chu ho moi
      ground.num_citizens -= 1
      ground.num_water_deal -= 1 if @citizen.is_water_deal
      ground.owner_id = nil
      ground.save!
      flash.now[:success] = "Chủ hộ #{@citizen.name} đã rời khỏi mặt bằng #{ground.name}"
      History.log(current_account, "Chủ hộ #{@citizen.name} đã rời khỏi mặt bằng #{ground.name}")
    end

    respond_to do |format|
      if close.present?
        format.js { render :serviceclose }
      elsif flash.now[:danger].present?
        format.js { render :layout_messages }
      else
        @groundhistory = GroundHistory.paginate(:page => params[:page], :per_page => 10)
        format.js { render :servicesuccess }
      end
    end
  end

  def payout
    @pay_type = []
    @ground = Ground.find_by(:id => params[:ground_id])
    begin
      # pay for service
      if params[:service_id].present?
        @service = Service.find(params[:service_id])
        @service.payout
        InforServiceJob.perform_in(30, @service, Apartment::Tenant.current)
        History.log(current_account, "Thanh toán phí chung cho #{@ground.name} tháng #{@service.started_time.month}")
        @pay_type.push("service")
      end
      # pay for water
      if params[:water_id].present?
        @water = Water.find(params[:water_id])
        @water.payout
        InforWaterJob.perform_in(30, @water, Apartment::Tenant.current)
        History.log(current_account, "Thanh toán phí nước cho #{@ground.name} tháng #{@water.started_time.month}")
        @pay_type.push("water")
      end
      # pay for vehicle finance
      if params[:vehicle_finance_id].present?
        @vehicle_finances = current_vehicle_finances(@ground)
        if @vehicle_finances.present?
          @vehicle_finances.each do |vehicle_finance|
            @vehicle_finances_ids = @vehicle_finances.map(&:id).join('-')
            vehicle_finance.payout
            InforVehicleJob.perform_in(30, vehicle_finance, Apartment::Tenant.current)
            History.log(current_account, "Thanh toán phí xe cho #{vehicle_finance.id} tháng #{vehicle_finance.started_time.month}")
          end
          @pay_type.push("vehicle_finance")
        end
      end
    rescue Exception => msg
      @exception_messages = "#{msg}. Có thể bạn đã thanh toán ở mặt bằng này rồi!";
    end

    respond_to do |format|
      if @exception_messages.present?
        format.js { render :payout_failed }
      else
        @success_content = "Thanh toán thành công và đã đóng các dịch vụ của #{@ground.name}"
        flash.now[:success] = "Thanh toán thành công và đã đóng các dịch vụ của #{@ground.name}"
        @ground.update(:status => Ground::STATUS_BOUGHT)
        History.log(current_account, "Đóng dịch vụ #{@ground.name}")
        format.js { render :payout_success }
      end
    end
  end

  def liabilities
    if params[:ground_id].blank?
      flash.now[:danger] = 'Hãy chọn mặt bằng trưóc khi thực hiện'
    elsif params[:started_time].blank?
      flash.now[:danger] = 'Hãy chọn tháng bắt đầu trưóc khi thực hiện'
    elsif params[:end_time].blank?
      flash.now[:danger] = 'Hãy chọn tháng kết thúc trước khi thực hiện'
    else
      @ground_id = params[:ground_id]
      @started_time_report = params[:started_time]
      @end_time_report = params[:end_time]

      params[:started_time] = Date.strptime(params[:started_time], "%m/%Y").change(:day => 1)
      params[:end_time] = Date.strptime(params[:end_time], "%m/%Y").end_of_month

      if params[:started_time] >= Date.today.end_of_month
        flash.now[:danger] = 'Tháng bắt đầu phải nhỏ hơn tháng hiện tại'
      elsif params[:started_time] > params[:end_time]
        flash.now[:danger] = 'Tháng kết thúc phải lớn hơn hoặc bằng tháng bắt đầu '
      else
        @debt_water = Water.where('waters.ground_id = ?
          AND waters.started_time >= ? AND waters.started_time <= ?',
          params[:ground_id], params[:started_time], params[:end_time]).sum(:debt)
        @paid_water = Water.where('waters.ground_id = ?
          AND waters.started_time >= ? AND waters.started_time <= ?',
          params[:ground_id], params[:started_time], params[:end_time]).sum(:paid)
        @fee_water = Water.where('waters.ground_id = ?
          AND waters.started_time >= ? AND waters.started_time <= ?',
          params[:ground_id], params[:started_time], params[:end_time]).sum(:fee)

        @debt_service = Service.where('services.ground_id = ?
          AND services.started_time >= ? AND services.started_time <= ?',
          params[:ground_id], params[:started_time], params[:end_time]).sum(:debt)
        @paid_service = Service.where('services.ground_id = ?
          AND services.started_time >= ? AND services.started_time <= ?',
          params[:ground_id], params[:started_time], params[:end_time]).sum(:paid)
        @fee_service = Service.where('services.ground_id = ?
          AND services.started_time >= ? AND services.started_time <= ?',
          params[:ground_id], params[:started_time], params[:end_time]).sum(:fee)

        @debt_vehicle = VehicleFinance.where('vehicle_finances.ground_id = ?
          AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
          params[:ground_id], params[:started_time], params[:end_time]).sum(:debt)
        @paid_vehicle = VehicleFinance.where('vehicle_finances.ground_id = ?
          AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
          params[:ground_id], params[:started_time], params[:end_time]).sum(:paid)
        @fee_vehicle = VehicleFinance.where('vehicle_finances.ground_id = ?
          AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
          params[:ground_id], params[:started_time], params[:end_time]).sum(:fee)

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

  def show_images
    @ground = Ground.find_by_id(params[:ground_id])
    respond_to do |format|
      format.js { render :show_images }
    end
  end

  def upload_images
    @ground = Ground.find(params["ground_id"])

    respond_to do |format|
      if @ground.update(image_ground_params)
        flash.now[:success] = "Thêm hình ảnh của mặt bằng #{@ground.name} thành công"
        format.js { render :image_success }
      else
        flash.now[:danger] = "Thêm hình ảnh của mặt bằng #{@ground.name} thất bại"
        format.js { render :image_failed }
      end
    end
  end

  private
    def ground_params
      params.require(:ground).permit(:name, :area_length, :area_width,
        :building_id, :kind, :floor, :num_rooms)
    end

    def ground_service_params
      params.require(:ground).permit(:status)
    end

    def citizen_params
      params.require(:citizen).permit(:name, :government_id,
        :phone, :email, :gender, :hometown, :dob, :nationality, :is_water_deal)
    end

    def image_ground_params
      params.require(:ground).permit({images: []})
    end
end
