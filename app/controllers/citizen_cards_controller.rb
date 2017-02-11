class CitizenCardsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_citizen_card, only: [:update, :destroy]
  before_action :authenticate_account!
  require 'will_paginate/array'

  def index
    @citizen_card = CitizenCard.new
    @citizen_cards = get_citizen_cards

    respond_to do |format|
      format.html {}
      format.js {}
      format.csv { send_data CitizenCard.all.to_csv }
      format.xls {
        filename = "CitizenCard-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        send_data(CitizenCard.all.order(:id).to_xls(:only => CitizenCard::HEADER_COLUMNS,
            :header_columns => CitizenCard::HEADERS),
            type: "text/xls; charset=utf-8; header=present",
            filename: filename
        )
      }
      format.json { render json: @citizen_cards }
    end
  end

  def export
    respond_to do |format|
      hash = Hash[[CitizenCard::HEADERS_TEMPLATE,CitizenCard::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-the-cu-dan.xls")
      }
    end
  end

  def import
    if params[:file].present?
      begin
        count = CitizenCard.import(params[:file])
        flash.now[:success] = "Nhập dữ liệu thẻ cư dân từ file excel thành công, thêm #{count} thẻ cư dân"
        History.log(current_account, "Import thêm #{count} thẻ cư dân")
      rescue Exception => msg
        flash.now[:danger] = "#{msg}. Không thêm dữ liệu nào"
      end
    else
      flash.now[:danger] = "Vui lòng nhập file Excel"
    end

    respond_to do |format|
      format.js {
        @citizen_cards = get_citizen_cards
        render :index
      }
    end
  end

  def create
    @citizen_card = CitizenCard.new(citizen_card_params)
    respond_to do |format|
      if @citizen_card.save
        flash.now[:success] = "Thêm thẻ cư dân thành công"
        History.log(current_account, "Tạo thẻ cư dân #{@citizen_card.id} của mặt bằng #{@citizen_card.ground_name}")
        format.html { redirect_to citizen_cards_path }
        format.js {
          @citizen_cards = get_citizen_cards
          render :index, status: :created, location: @citizen_card
        }
      else
        format.js { render json: @citizen_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      @citizen_card.attributes = citizen_card_params
      changes = @citizen_card.changes
      if @citizen_card.save
        flash[:success] = "Cập nhật thẻ cư dân #{@citizen_card.id} thành công"
        History.log(current_account, "Sửa thẻ cư dân #{@citizen_card.id}", changes, CitizenCard::VNI_COLUMNS)
        format.html { redirect_to citizen_cards_path }
        format.js { render :js => "window.location.replace('#{citizen_cards_path}');" }
      else
        format.js { render json: @citizen_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @citizen_card.update_attribute(:status, CitizenCard::STATUS_LOCK)
    flash[:success] = "Thẻ cư dân '#{@citizen_card.id}' tạm ngừng hoạt động"
    History.log(current_account, "Ngừng hoạt động thẻ cư dân #{@citizen_card.id}")
    redirect_to citizen_cards_path
  end

  private
    def set_citizen_card
      @citizen_card = CitizenCard.find(params[:id])
    end

    def citizen_card_params
      params.require(:citizen_card).permit(:card_no, :ground_id, :status)
    end

    def get_citizen_cards
      citizen_cards = CitizenCard.search(params[:search])
      if params[:status].present?
        citizen_cards = citizen_cards.where(:status => params[:status])
      end
      if sort_column == 'ground_id'
        citizen_cards = citizen_cards.sort_by(&:ground_name)
        citizen_cards = citizen_cards.reverse if params[:direction] == 'desc'
      else
        citizen_cards = citizen_cards.order(sort_column + " " + sort_direction)
      end
      return citizen_cards.paginate(page: params[:page], per_page: 8)
    end

    def sort_column
      CitizenCard.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
