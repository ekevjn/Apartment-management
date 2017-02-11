class GroundsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_ground, only: [:update, :destroy]
  before_action :authenticate_account!
  require 'will_paginate/array'
  include GroundsHelper

  def index
    @ground = Ground.new
    @grounds = get_grounds

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data Ground.all.to_csv }
      format.xls {
        filename = "Ground-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
          send_data(Ground.all.order(:id).to_xls(:only => Ground::HEADER_COLUMNS,
            :header_columns => Ground::HEADERS),
            type: "text/xls; charset=utf-8; header=present",
            filename: filename
        )
      }
      format.json { render json: @grounds }
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
      format.js {
        @grounds = get_grounds
        render :index
      }
    end
  end

  def autocomplete
    @ground = Ground.order(:name).where("lower(name) like ?", "%#{params[:term].downcase}%")
    render json: @ground.as_json
  end

  def create
    @ground = Ground.new(ground_params)
    respond_to do |format|
      if @ground.save
        flash.now[:success] = "Tạo mặt bằng #{@ground.name} thành công"
        History.log(current_account, "Tạo mặt bằng #{@ground.name}")
        format.js {
          @grounds = get_grounds
          render :index, status: :created, location: @ground
        }
      else
        format.js { render json: @ground.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      @ground.attributes = ground_params
      changes = @ground.changes
      if @ground.save
        flash[:success] = "Sửa mặt bằng #{@ground.name} thành công"
        History.log(current_account, "Sửa mặt bằng #{@ground.name}", changes, Ground::VNI_COLUMNS)
        format.js { render :js => "window.location.replace('#{grounds_path}');" }
      else
        format.js { render json: @ground.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if !exist_finances?(@ground)
      @ground.update_attribute(:del_flg, 1)
      History.log(current_account, "Ngừng hoạt động mặt bằng #{@ground.name}")
      flash[:success] = "Mặt bằng '#{@ground.name}' tạm ngưng hoạt động"
    else
      flash[:danger] = "Mặt bằng '#{@ground.name}' vẫn chưa thanh toán xong tiền dịch vụ. Vui lòng đóng dịch vụ trước khi hủy"
    end
    redirect_to grounds_path
  end

  private
    def set_ground
      @ground = Ground.find(params[:id])
    end

    def ground_params
      params.require(:ground).permit(:name, :area_length, :area_width,
        :kind, :floor, :building_id, :num_rooms, :active)
    end

    def get_grounds
      grounds = Ground.search(params[:search])
      if params[:type] == "active" || !params[:type]
        grounds = grounds.where(:del_flg => 0)
      elsif params[:type] == "deactive"
        grounds = grounds.where(:del_flg => 1)
      end
      if sort_column == 'building_id'
        grounds = grounds.sort_by(&:building_name)
        grounds = grounds.reverse if params[:direction] == 'desc'
      elsif sort_column == 'owner_id'
        grounds = grounds.sort_by(&:owner_name)
        grounds = grounds.reverse if params[:direction] == 'desc'
      else
        grounds = grounds.order(sort_column + " " + sort_direction)
      end
      return grounds.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      Ground.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
