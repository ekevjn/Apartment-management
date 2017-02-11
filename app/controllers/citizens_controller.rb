class CitizensController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_citizen, only: [:update, :destroy]
  before_action :authenticate_account!
  include GroundsHelper

  def index
    @citizen = Citizen.new
    @citizens = get_citizens

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data Citizen.all.to_csv }
      format.xls {
        filename = "Citizen-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        send_data(Citizen.all.order(:id).to_xls(:only => Citizen::HEADER_COLUMNS,
          :header_columns => Citizen::HEADERS),
          type: "text/xls; charset=utf-8; header=present",
          filename: filename)
      }
      format.json { render json: @citizens }
    end
  end

  def export
    respond_to do |format|
      hash = Hash[[Citizen::HEADERS_TEMPLATE,Citizen::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-cu-dan.xls")
      }
    end
  end

  def import
    if params[:file].present?
      begin
        count = Citizen.import(params[:file])
        flash.now[:success] = "Nhập dữ liệu cư dân từ file excel thành công, thêm #{count} cư dân"
        History.log(current_account, "Import thêm #{count} cư dân")
      rescue Exception => msg
        flash.now[:danger] = "#{msg}. Không thêm dữ liệu nào"
      end
    else
      flash.now[:danger] = "Vui lòng nhập file Excel"
    end

    respond_to do |format|
      format.js {
        @citizens = get_citizens
        render :index
      }
    end
  end

  def autocomplete
    @citizens = Citizen.order(:name).where("lower(name) like ?", "%#{params[:term].downcase}%")
    render json: @citizens.as_json
  end

  def create
    @citizen = Citizen.new(citizen_params)
    if params[:dob].blank?
      @citizen.dob = nil
    else
      @citizen.dob = Date.strptime(params[:dob], "%d/%m/%Y")
    end

    respond_to do |format|
      if @citizen.save
        flash.now[:success] = "Thêm cư dân thành công"
        History.log(current_account, "Tạo cư dân #{@citizen.name}")
        format.html { redirect_to citizens_path }
        format.js {
          @citizens = get_citizens
          render :index, status: :created, location: @citizen
        }
      else
        format.js { render json: @citizen.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @citizen.attributes = citizen_params

    if params[:dob].blank?
      @citizen.dob = nil
    else
      @citizen.dob = Date.strptime(params[:dob], "%d/%m/%Y")
    end

    respond_to do |format|
      changes = @citizen.changes
      if @citizen.save
        flash[:success] = "Cập nhật cư dân #{@citizen.name} thành công"
        History.log(current_account, "Sửa cư dân #{@citizen.name}", changes, Citizen::VNI_COLUMNS)
        format.html { redirect_to citizens_path }
        format.js { render :js => "window.location.replace('#{citizens_path}');" }
      else
        format.js { render json: @citizen.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @citizen.ground_id.present?
      flash[:danger] = "Cư dân #{@citizen.name} là thành viên của phòng #{@citizen.ground_name}. " +
          "Cư dân này cần rời đi trước khi hủy."
    else
      @citizen.update_attribute(:del_flg, 1)
      flash[:success] = "Cư dân '#{@citizen.name}' tạm ngừng hoạt động"
      History.log(current_account, "Ngừng hoạt động cư dân #{@citizen.name}")
    end
    redirect_to citizens_path
  end

  private
    def set_citizen
      @citizen = Citizen.find(params[:id])
    end

    def citizen_params
      params.require(:citizen).permit(:name, :ground_id,
        :government_id, :phone, :email, :gender, :dob,
        :hometown, :nationality, :is_water_deal, :active)
    end

    def get_citizens
      citizens = Citizen.search(params[:search])
      if params[:type] == "active" || !params[:type]
        citizens = citizens.where(:del_flg => 0)
      elsif params[:type] == "deactive"
        citizens = citizens.where(:del_flg => 1)
      end
      if sort_column == 'ground_id'
        citizens = citizens.sort_by(&:ground_name)
        citizens = citizens.reverse if params[:direction] == 'desc'
      else
        citizens = citizens.order(sort_column + " " + sort_direction)
      end
      return citizens.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      Citizen.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
