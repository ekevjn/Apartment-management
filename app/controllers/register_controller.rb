class RegisterController < ApplicationController

  def choose
    #render layout: false
  end

  def new
    chosenPlan = params[:plan]
    @tower = Tower.new
    render layout: false
  end

  def create
    @tower = Tower.new(tower_params)
    respond_to do |format|
      if @tower.save
        SubdomainActivationJob.perform_in(15, @tower)
        format.js { render :create_success }
      else
        puts @tower.errors.to_hash
        format.js { render json: @tower.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    tower = Tower.find_by(email: params[:email])
    if tower && !tower.active && tower.authenticated?(params[:id])
      tower.update_attribute(:del_flg,  0)
      flash[:success] = "Chung cư đã hoạt động, bạn đã có thể sử dụng subdomain #{tower.subdomain}"
    else
      flash[:danger] = "Link không hợp lệ"
    end
    render layout: false
  end

  private
    def tower_params
      params.require(:tower).permit(:name, :phone, :subdomain, :email,
        :manager_name, :password, :password_confirmation, :picture)
    end
end
