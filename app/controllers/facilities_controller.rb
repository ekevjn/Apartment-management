class FacilitiesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_facility, only: [:update, :destroy]
  before_action :authenticate_account!
  require 'will_paginate/array'

  def index
    @facility = Facility.new
    @facilities = get_facilities

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data Facility.all.to_csv }
      format.xls {
        filename = "Facility-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
          send_data(Facility.all.order(:id).to_xls(:only => Facility::HEADER_COLUMNS,
            :header_columns => Facility::HEADERS),
            type: "text/xls; charset=utf-8; header=present",
            filename: filename
          )
      }
      format.json { render json: @facilities }
    end
  end

  def export
    respond_to do |format|
      hash = Hash[[Facility::HEADERS_TEMPLATE,Facility::HEADERS_TEMPLATE].transpose]
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
      flash.now[:danger] = "Vui lòng nhập file Excel"
    end

    respond_to do |format|
      format.js {
        @facilities = get_facilities
        render :index
      }
    end
  end

  def autocomplete
    @facility = Facility.order(:name).where("lower(name) like ?", "%#{params[:term].downcase}%")
    render json: @facility.as_json
  end

  def create
    @facility = Facility.new(facility_params)

    respond_to do |format|
      if @facility.save
        flash.now[:success] = "Tạo tài sản #{@facility.name} thành công"
        History.log(current_account, "Tạo tài sản #{@facility.name}")
        format.js {
          @facilities = get_facilities
          render :index, status: :created, location: @facility
        }
      else
        format.js { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      @facility.attributes = facility_params
      changes = @facility.changes
      if @facility.save
        flash[:success] = "Sửa tài sản #{@facility.name} thành công"
        History.log(current_account, "Sửa tài sản #{@facility.name}", changes, Facility::VNI_COLUMNS)
        format.js { render :js => "window.location.replace('#{facilities_path}');" }
      else
        format.js { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @facility.update_attribute(:del_flg, 1)
    History.log(current_account, "Ngừng hoạt động tài sản #{@facility.name}")
    flash[:success] = "Tài sản '#{@facility.name}' tạm ngưng hoạt động"

    redirect_to facilities_path
  end

  private
    def set_facility
      @facility = Facility.find(params[:id])
    end

    def facility_params
      params.require(:facility).permit(:name, :status, :position,
        :building_id, :guarantee_time, :guarantee_company, :buy_time, :active)
    end

    def get_facilities
      facilities = Facility.search(params[:search])
      if params[:type] == "active" || !params[:type]
        facilities = facilities.where(:del_flg => 0)
      elsif params[:type] == "deactive"
        facilities = facilities.where(:del_flg => 1)
      end
      if sort_column == 'building_id'
        facilities = facilities.sort_by(&:building_name)
        facilities = facilities.reverse if params[:direction] == 'desc'
      else
        facilities = facilities.order(sort_column + " " + sort_direction)
      end
      return facilities.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      Facility.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
