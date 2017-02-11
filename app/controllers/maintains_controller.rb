class MaintainsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_maintain, only: [:update, :destroy]
  before_action :authenticate_account!
  require 'will_paginate/array'

  def index
    @maintain = Maintain.new
    @maintains = get_maintains

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data Maintain.all.to_csv }
      format.xls {
        filename = "Maintain-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
          send_data(Maintain.all.order(:id).to_xls(:only => Maintain::HEADER_COLUMNS,
            :header_columns => Maintain::HEADERS),
            type: "text/xls; charset=utf-8; header=present",
            filename: filename
        )
      }
      format.json { render json: @maintains }
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
        flash.now[:success] = "Nhập dữ liệu sửa chưa tài sản từ file excel thành công, thêm #{count} vé"
        History.log(current_account, "Import thêm #{count} thông tin bảo trì")
      rescue Exception => msg
        flash.now[:danger] = "#{msg}. Không thêm dữ liệu nào"
      end
    else
      flash.now[:danger] = "Vui lòng nhập file Excel"
    end

    respond_to do |format|
      format.js {
        @maintains = get_maintains
        render :index
      }
    end
  end

  def create
    @maintain = Maintain.new(maintain_params)

    respond_to do |format|
      if @maintain.save
        flash.now[:success] = "Tạo thông tin bảo trì #{@maintain.facility_id} thành công"
        History.log(current_account, "Tạo thông tin bảo trì #{@maintain.facility_id}")
        format.js {
          @maintains = get_maintains
          render :index, status: :created, location: @maintain
        }
      else
        format.js { render json: @maintain.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      @maintain.attributes = maintain_params
      changes = @maintain.changes
      if @maintain.save
        flash[:success] = "Sửa thông tin bảo trì #{@maintain.facility_name} thành công"
        History.log(current_account, "Sửa thông tin bảo trì #{@maintain.facility_name}", changes, Maintain::VNI_COLUMNS)
        format.js { render :js => "window.location.replace('#{maintains_path}');" }
      else
        format.js { render json: @maintain.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @maintain.update_attribute(:del_flg, 1)
    History.log(current_account, "Xóa thông tin bảo trì #{@maintain.facility_name} với id = #{@maintain.id}")
    flash[:success] = "Xóa thông tin bảo trì '#{@maintain.facility_name}' với id = #{@maintain.id}"

    redirect_to maintains_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_maintain
      @maintain = Maintain.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def maintain_params
      params.require(:maintain).permit(:facility_id, :fixed_time,
           :price, :description, :active)
    end

    def get_maintains
      maintains = Maintain.search(params[:search])
      if params[:type] == "active" || !params[:type]
        maintains = maintains.where(:del_flg => 0)
      elsif params[:type] == "deactive"
        maintains = maintains.where(:del_flg => 1)
      end
      if sort_column == 'facility_id'
        maintains = maintains.sort_by(&:facility_name)
        maintains = maintains.reverse if params[:direction] == 'desc'
      else
        maintains = maintains.order(sort_column + " " + sort_direction)
      end
      return maintains.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      Maintain.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
