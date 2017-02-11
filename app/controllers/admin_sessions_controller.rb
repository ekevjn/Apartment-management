class AdminSessionsController < ApplicationController
  def new
  end

  def create
    admin = Admin.find_by(email: params[:session][:email].downcase)
    if admin && admin.authenticate(params[:session][:password])
      admin_log_in admin
      flash[:success] = 'Đăng nhập với quyền admin thành công'
      redirect_to towers_path
    else
      flash.now[:danger] = 'Email hoặc mật khẩu không chính xác'
      render 'new'
    end
  end

  def destroy
    flash[:info] = "Đăng xuất với quyền admin thành công"
    admin_log_out
    redirect_to root_url
  end
end
