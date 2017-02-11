class SettingController < ApplicationController
  before_action :authenticate_account!
  before_action :check_manager, only: [:create_account, :update_account]
  #skip_before_action :verify_authenticity_token, :only => [:update, :setting_report]

  def index
    @tower = Tower.find_by_subdomain(Apartment::Tenant.current)
  end

  def update
    @tower = Tower.find_by_subdomain(Apartment::Tenant.current)

    respond_to do |format|
      @tower.attributes = tower_params_finance
      changes = @tower.changes
      if @tower.save
        History.log(current_account, "Sửa tòa nhà #{@tower.name}", changes, Tower::VNI_COLUMNS)
        flash.now[:success] = "Cập nhật dữ liệu tài chính thành công"
        format.js { render :settingsuccess }
      else
        format.js { render json: @tower.errors, status: :unprocessable_entity }
      end
    end
  end

  def report
    @tower = Tower.find_by_subdomain(Apartment::Tenant.current)

    respond_to do |format|
      @tower.attributes = tower_params_report
      changes = @tower.changes
      if @tower.save
        History.log(current_account, "Sửa tòa nhà #{@tower.name}", changes, Tower::VNI_COLUMNS)
        format.js { render :settingsuccess }
      else
        format.js { render json: @tower.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload_picture
    @tower = Tower.find_by_subdomain(Apartment::Tenant.current)

    respond_to do |format|
      begin
        if @tower.update(picture_tower_params)
          format.js { render :upload_picture_success }
        else
          flash.now[:danger] = "Thay đổi hình ảnh thất bại"
          format.js { render :layout_messages }
        end
      rescue Exception => msg
        flash.now[:danger] = "Thay đổi hình ảnh thất bại"
        format.js { render :layout_messages }
      end
    end
  end

  def create_account
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        History.log(current_account, "Tạo tài khoản #{@account.email}")
        format.js { render :setting_account_success }
      else
        format.js { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_account
    @account = Account.find_by_email(params["email"])

    respond_to do |format|
      # check old account
      if @account.present?
        @account.password = params["password"]
        @account.password_confirmation = params["password_confirmation"]
      end
      if @account.present? && params["password"].present? && @account.save
        History.log(current_account, "Thay đổi mật khẩu tài khoản #{@account.email}")
        format.js { render :setting_account_success }
      else
        if @account.blank?
          @account = Account.new
          @account.errors.add(:email, :not_specified, message: "tài khoản không tồn tại")
        elsif params["password"].blank?
          @account = Account.new
          @account.errors.add(:password, :not_specified, message: "không được để trống")
        end
        format.js { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def deactive_account
    @account = Account.find(params["id"])
    respond_to do |format|
      if @account.blank? || params["del_flg"].blank?
        flash.now[:danger] = "Đường dẫn không chính xác"
        format.js { render :layout_messages }
      elsif @account.is_manager
        flash.now[:danger] = "Bạn không thể thay đổi tài khoản chính"
        format.js { render :layout_messages }
      else
        if params["del_flg"] == '0'
          flash.now[:success] = "Tài khoản #{@account.email} đã mở hoạt động"
          @account.update(:del_flg => 0)
        else
          flash.now[:success] = "Tài khoản #{@account.email} đã ngừng hoạt động"
          @account.update(:del_flg => 1)
        end
        format.js { render :deactive_account }
      end
    end
  end

  private
    def tower_params_finance
      params.require(:tower).permit(:payment_date, :price_service, :price_hygiene,
        :price_water_lv1, :price_water_lv2, :price_water_lv3, :price_bicycle,
        :price_electric_bicycle, :price_motorbike, :price_car_4_seat, :price_car_7_seat)
    end

    def tower_params_report
      params.require(:tower).permit(:manager_name, :management_board,
        :bank_no, :receiver_name, :bank_name, :bank_eng)
    end

    def picture_tower_params
      params.require(:tower).permit(:picture)
    end

    def account_params
      params.require(:account).permit(:email, :password, :password_confirmation)
    end

    def check_manager
      if !current_account.is_manager
        flash[:success] = "Bạn phải là ban quản trị để thực hiện việc này"
        redirect_to dashboard_index_path
      end
    end
end
