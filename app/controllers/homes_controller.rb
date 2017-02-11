class HomesController < ApplicationController
  before_action :authenticate_account!, except: [:index]

  def index
    if isSubDomain?
      @posts = Post.all.order("updated_at desc").paginate(page: params[:page], per_page: 5)
      @sub_page = true
      render 'index'
    else
      render layout: false
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        flash[:success] = "Sửa thông tin thành công"
        format.js {
          render :editpostsuccess
        }
      else
        format.js { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def post_params
      params.require(:post).permit(:title, :content)
    end
end

