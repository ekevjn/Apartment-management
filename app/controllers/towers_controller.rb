class TowersController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_tower, only: [:update, :destroy, :reset_password]
  before_action :admin_user

  def index
    @towers = Tower.search(params[:search]).
                    order(sort_column + " " + sort_direction).
                    paginate(page: params[:page], per_page: 8)
    if params[:type] == "active"
      @towers = @towers.where(:del_flg => 0)
    elsif params[:type] == "deactive"
      @towers = @towers.where(:del_flg => 1)
    end

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data Tower.all.to_csv }
      format.xls {
        filename = "Towers-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        send_data(Tower.all.order(:id).to_xls(:only => Tower::HEADER_COLUMNS,
          :header_columns => Tower::HEADERS),
          type: "text/xls; charset=utf-8; header=present",
          filename: filename)
      }
      format.json { render json: @towers }
    end
  end

  def export
    respond_to do |format|
      hash = Hash[[Tower::HEADERS_TEMPLATE,Tower::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "tower-template.xls")
      }
    end
  end

  def import
    if params[:file].present?
      begin
        count = Tower.import(params[:file])
        flash[:success] = "Nhập dữ liệu mặt bằng từ file excel thành công, thêm #{count} tòa nhà"
      rescue Exception => msg
        flash[:danger] = "#{msg}. Không thêm dữ liệu nào";
      end
    else
      flash[:danger] = "Vui lòng nhập file Excel"
    end
    redirect_to towers_path
  end

  def update
    if @tower.update(tower_params)
      flash[:success] = "Cập nhật chung cư #{@tower.name} thành công"
    else
      flash[:danger] = "Cập nhật chung cư #{@tower.name} thất bại. #{@tower.errors.full_messages}"
    end
    redirect_to towers_path
  end

  def destroy
    @tower.update_attribute(:del_flg, 1)
    flash[:success] = "Chung cư '#{@tower.name}' ngừng hoạt động"
    redirect_to towers_path
  end

  def reset_password
    if @tower.present?
      Apartment::Tenant.switch!(@tower.subdomain)
      acc = Account.find_by_email(@tower.email)
      acc.password = 'password'
      acc.password_confirmation = 'password'
      if acc.save
        flash[:success] = "Đã reset mật khẩu subdomain #{@tower.subdomain} về mặc định là 'password'"
      else
        flash[:danger] = "Không thành công. #{acc.errors.full_messages}"
      end
      Apartment::Tenant.switch!
    end
    redirect_to towers_path
  end

  private
    def set_tower
      @tower = Tower.find(params[:id])
    end

    def tower_params
      params.require(:tower).permit(:name, :area, :address,
        :phone, :email, :symbol, :fax, :taxcode, :status,
        :manager_name, :management_board, :bank_no,
        :receiver_name, :bank_name, :bank_eng, :picture, :active)
    end

    def admin_user
      if current_admin.nil?
        flash[:danger] = "Bạn phải đăng nhập với quyền admin để có thể truy cập được trang này"
        redirect_to admin_login_path
      end
    end

    def sort_column
      Tower.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
