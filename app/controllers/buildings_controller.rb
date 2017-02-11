class BuildingsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_building, only: [:update, :destroy]
  before_action :authenticate_account!
  require 'will_paginate/array'

  def index
    @building = Building.new
    @buildings = get_buildings

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data Building.all.to_csv }
      format.xls {
        filename = "Building-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        send_data(Building.all.order(:id).to_xls(:only => Building::HEADER_COLUMNS,
          :header_columns => Building::HEADERS),
          type: "text/xls; charset=utf-8; header=present",
          filename: filename)
      }
      format.json { render json: @buildings }
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
      format.js {
        @buildings = get_buildings
        render :index
      }
    end
  end

  def create
    @building = Building.new(building_params)
    respond_to do |format|
      if @building.save
        flash.now[:success] = "Thêm tòa nhà thành công"
        History.log(current_account, "Tạo tòa nhà #{@building.name}")
        format.html { redirect_to buildings_path }
        format.js {
          @buildings = get_buildings
          render :index, status: :created, location: @building
        }
      else
        format.js { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      @building.attributes = building_params
      changes = @building.changes
      if @building.save
        flash[:success] = "Cập nhật tòa nhà #{@building.name} thành công"
        History.log(current_account, "Sửa tòa nhà #{@building.name}", changes, Building::VNI_COLUMNS)
        format.html { redirect_to buildings_path }
        format.js { render :js => "window.location.replace('#{buildings_path}');" }
      else
        format.js { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ground = Ground.find_by(:building_id => @building.id)
    if ground.present?
      flash[:danger] = "Mặt bằng #{ground.name} thuộc tòa nhà #{@building.name} này vẫn đang hoạt động. Vui lòng hủy hoạt động của các mặt bằng trong tòa nhà này trưóc"
    else
      @building.update_attribute(:del_flg, 1)
      flash[:success] = "Tòa nhà '#{@building.name}' tạm ngừng hoạt động"
      History.log(current_account, "Ngừng hoạt động tòa nhà #{@building.name}")
    end
    redirect_to buildings_path
  end

  private
    def set_building
      @building = Building.find(params[:id])
    end

    def building_params
      params.require(:building).permit(:name, :num_floors, :active)
    end

    def get_buildings
      buildings = Building.search(params[:search])
      if params[:type] == "active" || !params[:type]
        buildings = buildings.where(:del_flg => 0)
      elsif params[:type] == "deactive"
        buildings = buildings.where(:del_flg => 1)
      end
      buildings = buildings.order(sort_column + " " + sort_direction)
      return buildings.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      Building.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
