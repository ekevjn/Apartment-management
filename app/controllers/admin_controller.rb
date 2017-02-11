class AdminController < ApplicationController
  before_action :admin_user

  def change_password
    @admin = current_admin
  end

  def update_password
    @admin = current_admin
    if !@admin.authenticate(params[:current_password])
      flash.now[:danger] = "Mật khẩu hiện tại không chính xác"
    elsif params[:admin][:password].blank?
      flash.now[:danger] = "Mật khẩu mới không được để trống"
    elsif params[:admin][:password].size < 6
      flash.now[:danger] = "Mật khẩu mới phải có ít nhất 6 kí tự"
    elsif params[:admin][:password_confirmation] != params[:admin][:password]
      flash.now[:danger] = "Xác nhận mật khẩu không khớp"
    elsif @admin.update(admin_params)
      flash.now[:success] = "Mật khẩu đã được thay đổi"
    else
      flash.now[:danger] = @admin.errors.full_messages
    end
    render 'change_password'
  end

  private
    def admin_params
      params.require(:admin).permit(:password, :password_confirmation)
    end

    def admin_user
      if current_admin.nil?
        flash[:danger] = "Bạn cần đăng nhập với quyền admin để có thể truy cập được trang này"
        redirect_to admin_login_path
      end
    end
end
