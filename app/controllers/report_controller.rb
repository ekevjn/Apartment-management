class ReportController < ApplicationController
  before_action :authenticate_account!

  def payment
    @ground = Ground.find(params[:id])
    @service = Service.find_by(:ground_id => @ground.id, :is_current => true)
    @water = Water.find_by(:ground_id => @ground.id, :is_current => true)
    @owner = Citizen.find_by(:id => @ground.owner_id)
    render layout: false
  end

  def done_pay
    @ground = Ground.find(params[:id])
    @service = Service.find_by(:ground_id => @ground.id, :is_current => true)
    @water = Water.find_by(:ground_id => @ground.id, :is_current => true)
    @owner = Citizen.find_by(:id => @ground.owner_id)
    render layout: false
  end

  def done_pay_service
    @service = Service.find(params[:id])
    @ground = @service.ground
    @owner = Citizen.find_by(:id => @ground.owner_id)
    # prevent report if not enough condition
    @is_report = @service.present? && @owner.present?
    render layout: false
  end

  def done_pay_water
    @water = Water.find(params[:id])
    @ground = @water.ground
    @owner = Citizen.find_by(:id => @ground.owner_id)
    # prevent report if not enough condition
    @is_report = @water.present? && @owner.present?
    render layout: false
  end

  def done_pay_vehicle
    if params[:ids].present?
      vehicle_finances_ids = params[:ids].split("-")
      puts vehicle_finances_ids
      @vehicle_finances = VehicleFinance.where("id in (:ids)",
        { :ids => vehicle_finances_ids })
      puts @vehicle_finances
      if @vehicle_finances.present?
        # variable for reporting
        @vehicle_finances_date = @vehicle_finances.first.started_time
        @vehicle_finances_debt = 0
        @vehicle_finances_remain = 0
        @ground = Ground.find_by(:id => @vehicle_finances.first.ground_id)
        @owner = Citizen.find_by(:id => @ground.owner_id)
        @vehicle_finances.each do | vehicle_finance |
          @vehicle_finances_debt += vehicle_finance.debt
          @vehicle_finances_remain += vehicle_finance.remain
        end
      end
    end
    # prevent report if not enough condition
    @is_report = @vehicle_finances.present? && @owner.present?
    render layout: false
  end

  def liabilities_building_summary
    # @grounds = Ground.where(:id => params[:building_id])
    @building = Building.find(params[:building_id])
    @started_time_report = params[:started_time]
    @end_time_report = params[:end_time]

    params[:started_time] = Date.strptime(params[:started_time], "%m/%Y").change(:day => 1)
    params[:end_time] = Date.strptime(params[:end_time], "%m/%Y").end_of_month
    # waters = Water.where("ground_id in (?) AND .... ", @ground.map(&:id), )
    @debt_water = Water.joins(:ground).where('grounds.building_id = ?
      AND waters.started_time >= ? AND waters.started_time <= ?',
      params[:building_id], params[:started_time], params[:end_time]).sum(:debt)
    @paid_water = Water.joins(:ground).where('grounds.building_id = ?
      AND waters.started_time >= ? AND waters.started_time <= ?',
      params[:building_id], params[:started_time], params[:end_time]).sum(:paid)
    @fee_water = Water.joins(:ground).where('grounds.building_id = ?
      AND waters.started_time >= ? AND waters.started_time <= ?',
      params[:building_id], params[:started_time], params[:end_time]).sum(:fee)

    @debt_service = Service.joins(:ground).where('grounds.building_id = ?
      AND services.started_time >= ? AND services.started_time <= ?',
      params[:building_id], params[:started_time], params[:end_time]).sum(:debt)
    @paid_service = Service.joins(:ground).where('grounds.building_id = ?
      AND services.started_time >= ? AND services.started_time <= ?',
      params[:building_id], params[:started_time], params[:end_time]).sum(:paid)
    @fee_service = Service.joins(:ground).where('grounds.building_id = ?
      AND services.started_time >= ? AND services.started_time <= ?',
      params[:building_id], params[:started_time], params[:end_time]).sum(:fee)

    @debt_vehicle = VehicleFinance.joins(:ground).where('grounds.building_id = ?
      AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
      params[:building_id], params[:started_time], params[:end_time]).sum(:debt)
    @paid_vehicle = VehicleFinance.joins(:ground).where('grounds.building_id = ?
      AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
      params[:building_id], params[:started_time], params[:end_time]).sum(:paid)
    @fee_vehicle = VehicleFinance.joins(:ground).where('grounds.building_id = ?
      AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
      params[:building_id], params[:started_time], params[:end_time]).sum(:fee)

    @debt = @debt_water + @debt_service + @debt_vehicle
    @paid = @paid_water + @paid_service + @paid_vehicle
    @fee = @fee_water + @fee_service + @fee_vehicle
    render layout: false
  end

  def liabilities_ground_summary
    @ground = Ground.find(params[:ground_id])

    params[:started_time] = Date.strptime(params[:started_time], "%m/%Y").change(:day => 1)
    params[:end_time] = Date.strptime(params[:end_time], "%m/%Y").end_of_month

    @debt_water = Water.where('waters.ground_id = ?
      AND waters.started_time >= ? AND waters.started_time <= ?',
      params[:ground_id], params[:started_time], params[:end_time]).sum(:debt)
    @paid_water = Water.where('waters.ground_id = ?
      AND waters.started_time >= ? AND waters.started_time <= ?',
      params[:ground_id], params[:started_time], params[:end_time]).sum(:paid)
    @fee_water = Water.where('waters.ground_id = ?
      AND waters.started_time >= ? AND waters.started_time <= ?',
      params[:ground_id], params[:started_time], params[:end_time]).sum(:fee)

    @debt_service = Service.where('services.ground_id = ?
      AND services.started_time >= ? AND services.started_time <= ?',
      params[:ground_id], params[:started_time], params[:end_time]).sum(:debt)
    @paid_service = Service.where('services.ground_id = ?
      AND services.started_time >= ? AND services.started_time <= ?',
      params[:ground_id], params[:started_time], params[:end_time]).sum(:paid)
    @fee_service = Service.where('services.ground_id = ?
      AND services.started_time >= ? AND services.started_time <= ?',
      params[:ground_id], params[:started_time], params[:end_time]).sum(:fee)

    @debt_vehicle = VehicleFinance.where('vehicle_finances.ground_id = ?
      AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
      params[:ground_id], params[:started_time], params[:end_time]).sum(:debt)
    @paid_vehicle = VehicleFinance.where('vehicle_finances.ground_id = ?
      AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
      params[:ground_id], params[:started_time], params[:end_time]).sum(:paid)
    @fee_vehicle = VehicleFinance.where('vehicle_finances.ground_id = ?
      AND vehicle_finances.started_time >= ? AND vehicle_finances.started_time <= ?',
      params[:ground_id], params[:started_time], params[:end_time]).sum(:fee)

    @debt = @debt_water + @debt_service + @debt_vehicle
    @paid = @paid_water + @paid_service + @paid_vehicle
    @fee = @fee_water + @fee_service + @fee_vehicle
    render layout: false
  end

  def report_list_citizen
    @citizens = Citizen.where(del_flg: 0).order(:id)
    render layout: false
  end

  def report_list_ground
    @grounds = Ground.all.order(:id)
    render layout: false
  end

  def report_list_vehicle_card
    @vehicle_cards = VehicleCard.all.order(:id)
    render layout: false
  end


  def report_list_facility
    @facilities = Facility.all.order(:id)
    render layout: false
  end




end
