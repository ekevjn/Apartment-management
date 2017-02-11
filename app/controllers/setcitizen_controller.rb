class SetcitizenController < ApplicationController
  before_action :authenticate_account!

  def index
    @citizen = Citizen.new
    @citizencard = CitizenCard.new
  end

  def create
    @citizen = Citizen.new(citizen_params)
    @citizen.dob = Date.strptime(params[:dob], "%d/%m/%Y") if params[:dob] != ''

    respond_to do |format|
      if @citizen.save
        History.log(current_account, "Tạo cư dân #{@citizen.name}")
        format.js { render :citizensuccess }
      else
        puts @citizen.errors.to_hash
        format.js { render json: @citizen.errors, status: :unprocessable_entity }
      end
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
        flash.now[:danger] = "#{msg}. Không thêm dữ liệu nào";
      end
    else
      flash.now[:danger] = "Vui lòng nhập file Excel"
    end
    respond_to do |format|
      format.js { render :layout_messages }
    end
  end

  def create_citizen_card
    @citizen_card = CitizenCard.new(citizen_card_params)
    @citizen_card.status = CitizenCard::STATUS_AVAILABLE
    respond_to do |format|
      if @citizen_card.save
        History.log(current_account, "Tạo thẻ cư dân #{@citizen_card.id} của mặt bằng #{@citizen_card.ground_name}")
        format.js { render :citizencardsuccess }
      else
        puts @citizen_card.errors.to_hash
        format.js { render json: @citizen_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_citizen_card
    respond_to do |format|
      hash = Hash[[CitizenCard::HEADERS_TEMPLATE,CitizenCard::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-the-cu-dan.xls")
      }
    end
  end

  def import_citizen_card
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
      format.js { render :layout_messages }
    end
  end

  def citizen_card_close
    respond_to do |format|
      if params["ground_id"].present?
        @ground_cards = CitizenCard.where(:ground_id => params["ground_id"])
        format.js { render :groundcard }
      else
        flash.now[:danger] = "Hãy chọn mặt bằng"
        format.js { render :layout_messages }
      end
    end
  end

  def citizen_card_lock
    @ground_card = CitizenCard.find(params[:id])
    @ground_card.status = CitizenCard::STATUS_LOCK
    @ground_card.save
    @ground_cards = CitizenCard.where(:ground_id => params["ground_id"])
    respond_to do |format|
      format.js{
        render :groundcard
      }
    end
  end

  def citizen_card_lost
    @ground_card = CitizenCard.find(params[:id])
    @ground_card.status = CitizenCard::STATUS_LOST
    @ground_card.save
    @ground_cards = CitizenCard.where(:ground_id => params["ground_id"])
    respond_to do |format|
      format.js{
        render :groundcard
      }
    end
  end


  private
    def citizen_params
      params.require(:citizen).permit(:name, :ground_id,
        :government_id, :phone, :email, :gender, :dob,
        :hometown, :nationality, :is_water_deal, :active)
    end

    def citizen_card_params
      params.require(:citizen_card).permit(:ground_id, :status, :card_no, :del_flg)
    end
end
