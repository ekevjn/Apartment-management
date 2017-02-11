class HistoriesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :authenticate_account!
  before_action :check_manager

  def index
    @histories = History.search(params[:search]).
                    order(sort_column + " " + sort_direction).
                    paginate(page: params[:page], per_page: 8)
    if params[:filter_date].present?
        # filter_date format: m/yyyy
        fd = params[:filter_date].split("/")
        if fd.present? && fd.size == 2
          @histories = @histories.where('extract(month from created_at) = ? AND extract(year from created_at) = ?', fd[0], fd[1])
        end
    end
    respond_to do |format|
      format.html {}
      format.js {}
      format.xls {
        filename = "History-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
          send_data(History.all.order(:id).to_xls(:only => History::HEADER_COLUMNS,
            :header_columns => History::HEADERS),
            type: "text/xls; charset=utf-8; header=present",
            filename: filename
          )
      }
      format.json { render json: @histories }
    end
  end

  private
    def check_manager
      if !current_account.is_manager
        flash[:success] = "Bạn phải là ban quản trị để thực hiện việc này"
        redirect_to grounds_path
      end
    end

    def sort_column
      History.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
