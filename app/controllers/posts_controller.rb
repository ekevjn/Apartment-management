class PostsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_post, only: [:update, :destroy]

  def index
    @post = Post.new
  end

  def create
    @post = Post.new
    @post.title = params[:title]
    @post.content = params[:content]

    respond_to do |format|
      if @post.save
        History.log(current_account, "Thêm bài đăng #{@post.title}")
        format.js { render :postsuccess }
      else
        format.js {render json: @post.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        flash.now[:success] = "Sửa bài thông báo thành công"
        History.log(current_account, "Cập nhật nội dung bài đăng #{@post.title}")
        format.js { render :js => "window.location.replace('#{root_path}');" }
      else
        format.js { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      post = Post.find(params[:id])
      title = post.title
      if post.destroy
        flash.now[:success] = "Xóa thông tin bài viết thành công"
        History.log(current_account, "Xóa bài đăng #{title}")
        format.html { redirect_to root_path }
      else
        format.js { render :destroy_failed, status: :unprocessable_entity }
      end
    end
  end

  def send_mail
    @citizen = Citizen.find_by(:id => params[:citizen_id])

    if @citizen.present?
      @email = @citizen.email
      if @email.blank? && @citizen.ground_id.present?
        ground = @citizen.ground
        if ground.owner_id.present?
          owner = Citizen.find_by(:id => ground.owner_id)
          if owner.present? && owner.email.present?
            @email = owner.email
            @is_owner = true
          end
        end
      end
    end

    if @email.blank?
      @error_messages = 'Không xác định email của cư dân'
    elsif params[:title].blank?
      @error_messages = "Không có tiêu đề"
    elsif params[:content].blank?
      @error_messages = "Vui lòng điền nội dung"
    else
      SendEmailJob.perform_in(5, @email, params[:title], params[:content], Apartment::Tenant.current)
    end

    respond_to do |format|
      format.js { render :send_mail }
    end
  end

  private
    def post_params
      params.require(:post).permit(:title, :content)
    end

    def set_post
      @post = Post.find(params[:id])
    end
end
