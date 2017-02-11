class SetmaintainController < ApplicationController
  before_action :authenticate_account!

  def index
    @maintain = Maintain.new
  end

  def create
    @maintain = Maintain.new(maintain_params)
    respond_to do |format|
      if @maintain.save
        format.js {
          render :maintainsuccess, status: :created, location: @maintain
        }
      else
        format.js {
          render json: @maintain.errors, status: :unprocessable_entity
        }
      end
    end
  end

  def export
    respond_to do |format|
      hash = Hash[[Maintain::HEADERS_TEMPLATE,Maintain::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-bao-tri.xls")
      }
    end
  end

  def import
    if params[:file].present?
      begin
        count = Maintain.import(params[:file])
        flash.now[:success] = "Nhập dữ liệu bảo trì từ file excel thành công, thêm #{count} thông tin"
        History.log(current_account, "Import thêm #{count} thông tin bảo trì")
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
    def maintain_params
      params.require(:maintain).permit(:facility_id, :fixed_time, :price, :description)
    end
end
