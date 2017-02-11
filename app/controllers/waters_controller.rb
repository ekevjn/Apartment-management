class WatersController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_water, only: [:update, :destroy]
  before_action :authenticate_account!
  require 'will_paginate/array'

  def index
    @water = Water.new
    @waters = get_waters

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data Water.all.to_csv }
      format.xls {
        filename = "Water-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        send_data(Water.all.order(:id).to_xls(:only => Water::HEADER_COLUMNS,
          :header_columns => Water::HEADERS),
        type: "text/xls; charset=utf-8; header=present",
        filename: filename
        )
      }
      format.json { render json: @waters }
    end
  end

  def create
    @water = Water.new(water_params)
    @water.started_time = Date.strptime(params[:started_time], "%m/%Y") if params[:started_time].present?

    if @water.ground_id.present? && @water.started_time.present?
      water_check = Water.where("ground_id = #{@water.ground_id} " +
          " AND extract(month from started_time) = #{@water.started_time.month} " +
          " AND extract(year from started_time) = #{@water.started_time.year}")
      if water_check.present?
        @water.errors.add(:started_time, :not_specified, message: "Đã tồn tại số nước của mặt bằng này trong tháng #{@water.started_time.month}")
      end
    end

    respond_to do |format|
      if water_check.blank? && @water.save
        flash.now[:success] = "Thêm dịch vụ nước thành công"
        History.log(current_account, "Tạo phí nước cho #{@water.ground_name}")
        format.js {
          @waters = get_waters
          render :index, status: :created, location: @water
        }
      else
        format.js { render json: @water.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @water.attributes = water_params
    changes = @water.changes

    respond_to do |format|
      if @water.save
        flash.now[:success] = "Cập nhật dịch vụ nước thành công"
        History.log(current_account, "Sửa phí nước #{@water.ground_name}", changes, Water::VNI_COLUMNS)
        format.js { render :js => "window.location.replace('#{waters_path}');" }
      else
        format.js { render json: @water.errors, status: :unprocessable_entity }
      end
    end
  end

  def pay
    @water = Water.find(params['ground_id'])
    @money_error = ''
    @money = params[:given_money].to_i
    if !is_integer(params[:given_money]) || @money == 0
      @money_error = "Số tiền không hợp lệ"
    elsif @money < @water.remain
      @money_error = "Thanh toán chưa đủ"
    else
      # pay for water
      @water.pay(@money)
      InforWaterJob.perform_in(30, @water, Apartment::Tenant.current)
    end

    respond_to do |format|
      if @money_error.present?
        format.js { render 'pay_failed' }
      else
        format.js {
          flash[:success] = "Thanh toán tiền nưóc cho #{@water.ground_name} " +
          "tháng #{@water.started_time.month} thành công. Vui lòng check mail"
          History.log(current_account, "Thanh toán phí nưóc cho #{@water.ground_name} tháng #{@water.started_time}")
          render :js => "window.location.replace('#{waters_path}');"
        }
      end
    end
  end

  def destroy
    @water.update_attribute(:is_current, false)
    flash[:success] = "Dịch vụ nước của #{@water.ground_name} tạm ngưng"
    History.log(current_account, "Ngừng phí nước của #{@water.ground_name}")
    redirect_to waters_path
  end


  private
    def set_water
      @water = Water.find(params[:id])
    end

    def water_params
      params.require(:water).permit(:ground_id, :water_no, :debt, :paid)
    end

    def get_waters
      waters = Water.search(params[:search])
      if params[:filter_date].present?
        # filter_date format: m/yyyy
        fd = params[:filter_date].split("/")
        if fd.present? && fd.size == 2
          waters = waters.where('extract(month from started_time) = ? AND extract(year from started_time) = ?', fd[0], fd[1])
        end
      elsif params[:type] == "active" || !params[:type]
        waters = waters.where(:is_current => true)
      elsif params[:type] == "deactive"
        waters = waters.where(:is_current => false)
      end

      if sort_column == 'ground_id'
        waters = waters.sort_by(&:ground_name)
        waters = waters.reverse if params[:direction] == 'desc'
      else
        waters = waters.order(sort_column + " " + sort_direction)
      end
      return waters.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      Water.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
