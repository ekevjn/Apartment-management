class SetfacilityController < ApplicationController
  before_action :authenticate_account!

  def index
    @facility = Facility.new
  end

  def create
    @facility = Facility.new(facility_params)
    respond_to do |format|
      if @facility.save
        format.js {
          render :facilitysuccess, status: :created, location: @facility
        }
      else
        format.js {
          render json: @facility.errors, status: :unprocessable_entity
        }
      end
    end
  end

  def export
    respond_to do |format|
      hash = Hash[[Facility::HEADERS_TEMPLATE, Facility::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-tai-san.xls")
      }
    end
  end

  def import
    if params[:file].present?
      begin
        count = Facility.import(params[:file])
        flash.now[:success] = "Nhập dữ liệu tài sản từ file excel thành công, thêm #{count} tài sản"
        History.log(current_account, "Import thêm #{count} tài sản")
      rescue Exception => msg
        flash.now[:danger] = "#{msg}. Không thêm dữ liệu nào"
      end
    else
      flash[:danger] = "Vui lòng nhập file Excel"
    end
    respond_to do |format|
      format.js { render :layout_messages }
    end
  end

  private
    def facility_params
      params.require(:facility).permit(:name, :status, :position,
          :building_id, :buy_time, :guarantee_time, :guarantee_company)
    end
end
