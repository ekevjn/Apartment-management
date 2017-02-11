class VehicleCardsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_vehicle_card, only: [:update, :destroy]
  before_action :authenticate_account!
  require 'will_paginate/array'

  def index
    @vehicle_card = VehicleCard.new
    @vehicle_cards = get_vehicle_cards

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data VehicleCard.all.to_csv }
      format.xls {
        filename = "VehicleCard-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        send_data(VehicleCard.all.order(:id).to_xls(:only => VehicleCard::HEADER_COLUMNS,
            :header_columns => VehicleCard::HEADERS),
            type: "text/xls; charset=utf-8; header=present",
            filename: filename
          )
      }
      format.json { render json: @vehicle_cards }
    end
  end

  def export
    respond_to do |format|
      hash = Hash[[VehicleCard::HEADERS_TEMPLATE,VehicleCard::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-the-xe.xls")
      }
    end
  end

  def import
    if params[:file].present?
      begin
        count = VehicleCard.import(params[:file])
        flash.now[:success] = "Nhập dữ liệu thẻ xe từ file excel thành công, thêm #{count} thẻ xe"
        History.log(current_account, "Import thêm #{count} thẻ xe")
      rescue Exception => msg
        flash.now[:danger] = "#{msg}"
      end
    else
      flash.now[:danger] = "Vui lòng nhập file Excel"
    end

    respond_to do |format|
      format.js {
        @vehicle_cards = get_vehicle_cards
        render :index
      }
    end
  end

  def autocomplete
    @cards = VehicleCard.order(:license_no).
      where("lower(card_no) like :param or lower(license_no) like :param",
          { :param => "%#{params[:term].downcase}%" })
    render json: @cards.as_json
  end

  def create
    @vehicle_card = VehicleCard.new(vehicle_card_params)
    @vehicle_card.started_time = Date.strptime(params[:started_time], "%m/%Y") if params[:started_time] != ''
    @vehicle_card.outdate_time = Date.strptime(params[:outdate_time], "%m/%Y") if params[:outdate_time] != ''
    @vehicle_card.registered_time = Date.strptime(params[:registered_time], "%d/%m/%Y") if params[:registered_time] != ''

    respond_to do |format|
      if @vehicle_card.save
        flash.now[:success] = "Thêm thẻ xe thành công"
        History.log(current_account, "Tạo thẻ xe #{@vehicle_card.card_no} của mặt bằng #{@vehicle_card.ground_name}")
        format.html { redirect_to vehicle_cards_path }
        format.js {
          @vehicle_cards = get_vehicle_cards
          render :index, status: :created, location: @vehicle_card
        }
      else
        format.js { render json: @vehicle_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @vehicle_card.attributes = vehicle_card_params

    if params[:started_time] == ''
      @vehicle_card.started_time = nil
    else
      @vehicle_card.started_time = Date.strptime(params[:started_time], "%m/%Y")
    end

    if params[:outdate_time] == ''
      @vehicle_card.outdate_time = nil
    else
      @vehicle_card.outdate_time = Date.strptime(params[:outdate_time], "%m/%Y")
    end

    if params[:registered_time] == ''
      @vehicle_card.registered_time = nil
    else
      @vehicle_card.registered_time = Date.strptime(params[:registered_time], "%d/%m/%Y")
    end

    respond_to do |format|
      changes = @vehicle_card.changes
      if @vehicle_card.save
        flash[:success] = "Cập nhật thẻ xe thành công"
        History.log(current_account, "Sửa thẻ xe #{@vehicle_card.card_no}", changes, VehicleCard::VNI_COLUMNS)
        format.html { redirect_to vehicle_cards_path }
        format.js { render :js => "window.location.replace('#{vehicle_cards_path}');" }
      else
        format.js { render json: @vehicle_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @vehicle_card.update_attribute(:status, VehicleCard::STATUS_LOCK)
    flash[:success] = "Thẻ xe '#{@vehicle_card.card_no}' đã ngừng hoạt động"
    History.log(current_account, "Ngừng hoạt động thẻ xe #{@vehicle_card.card_no}")
    redirect_to vehicle_cards_path
  end

  private
    def set_vehicle_card
      @vehicle_card = VehicleCard.find(params[:id])
    end

    def vehicle_card_params
      params.require(:vehicle_card).permit(:card_no, :license_no, :vehicle_type,
        :ground_id, :citizen_id, :status, :started_time, :created_fee,
        :outdate_time, :registered_time, :description)
    end

    def get_vehicle_cards
      vehicle_cards = VehicleCard.search(params[:search])
      if params[:status].present?
        vehicle_cards = vehicle_cards.where(:status => params[:status])
      end
      if sort_column == 'ground_id'
        vehicle_cards = vehicle_cards.sort_by(&:ground_name)
        vehicle_cards = vehicle_cards.reverse if params[:direction] == 'desc'
      elsif sort_column == 'citizen_id'
        vehicle_cards = vehicle_cards.sort_by(&:citizen_name)
        vehicle_cards = vehicle_cards.reverse if params[:direction] == 'desc'
      else
        vehicle_cards = vehicle_cards.order(sort_column + " " + sort_direction)
      end
      return vehicle_cards.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      VehicleCard.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
