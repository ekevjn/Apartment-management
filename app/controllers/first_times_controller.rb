class FirstTimesController < ApplicationController
  before_action :authenticate_account!

  def index
    @tower = Tower.find_by_subdomain(Apartment::Tenant.current)
  end

  def update_setting
    @tower = Tower.find_by_subdomain(Apartment::Tenant.current)

    respond_to do |format|
      @tower.attributes = tower_params
      changes = @tower.changes
      if @tower.save
        History.log(current_account, "Sửa tòa nhà #{@tower.name}", changes, Tower::VNI_COLUMNS)
        format.js { render :step1_setting_tower_done }
      else
        format.js { render json: @tower.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_building
    respond_to do |format|
      hash = Hash[[Building::HEADERS_TEMPLATE,Building::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-toa-nha.xls")
      }
    end
  end

  def export_ground
    respond_to do |format|
      hash = Hash[[Ground::HEADERS_TEMPLATE,Ground::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-mat-bang.xls")
      }
    end
  end

  def export_citizen
    respond_to do |format|
      hash = Hash[[Citizen::HEADERS_TEMPLATE,Citizen::HEADERS_TEMPLATE].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-cu-dan.xls")
      }
    end
  end

  def export_owner
    respond_to do |format|
      hash = Hash[[Ground::HEADERS_TEMPLATE_OWNER,Ground::HEADERS_TEMPLATE_OWNER].transpose]
      format.xls {
        send_data([hash].to_xls,
          type: "text/xls; charset=utf-8; header=present",
          filename: "template-chu-ho.xls")
      }
    end
  end

  def import_building
    if params[:file].present?
      begin
        count = Building.import(params[:file])
        History.log(current_account, "Import thêm #{count} tòa nhà")
      rescue Exception => msg
        @failed_messages = "#{msg}. Không thêm dữ liệu nào"
      end
    else
      @failed_messages = "Vui lòng nhập file Excel"
    end

    respond_to do |format|
      if @failed_messages.present?
        format.js { render :import_failed }
      else
        format.js { render :step2_import_building_done }
      end
    end
  end

  def import_ground
    if params[:file].present?
      begin
        count = Ground.import(params[:file])
        History.log(current_account, "Import thêm #{count} mặt bằng")
      rescue Exception => msg
        @failed_messages = "#{msg}. Không thêm dữ liệu nào"
      end
    else
      @failed_messages = "Vui lòng nhập file Excel"
    end

    respond_to do |format|
      if @failed_messages.present?
        format.js { render :import_failed }
      else
        format.js { render :step3_import_ground_done }
      end
    end
  end

  def import_citizen
    if params[:file].present?
      begin
        count = Citizen.import(params[:file])
        History.log(current_account, "Import thêm #{count} cư dân")
      rescue Exception => msg
        @failed_messages = "#{msg}. Không thêm dữ liệu nào"
      end
    else
      @failed_messages = "Vui lòng nhập file Excel"
    end

    respond_to do |format|
      if @failed_messages.present?
        format.js { render :import_failed }
      else
        format.js { render :step4_import_citizen_done }
      end
    end
  end

  private
    def tower_params
      params.require(:tower).permit(:payment_date, :price_service, :price_hygiene,
        :price_water_lv1, :price_water_lv2, :price_water_lv3,
        :price_bicycle, :price_electric_bicycle, :price_motorbike,
        :price_car_4_seat, :price_car_7_seat)
    end
end
