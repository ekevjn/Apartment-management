class GroundHistoriesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :authenticate_account!

  def index
    @ground_histories = GroundHistory.search(params[:search]).
                    order(sort_column + " " + sort_direction).
                    paginate(page: params[:page], per_page: 8)

    # dropdown for filter date
    @come_dates = GroundHistory.all.map { |d|
        if d.come_date.present?
          d.come_date.strftime('%m/%Y')
        else
          "chưa đến"
        end
    }.uniq.sort!
    @end_dates = GroundHistory.all.map { |d|
      if d.end_date.present?
        d.end_date.strftime('%m/%Y')
      else
        'chưa rời đi'
      end
    }.uniq.sort!

    # get selected when reload
    @selected_come_date = params[:come_date]
    @selected_end_date = params[:end_date]

    # filter by date
    if params[:come_date].present? && params[:end_date].present?
      # filter_date format: m/yyyy
        fdcome = params[:come_date].split("/")
        fdend = params[:end_date].split("/")
        if fdcome.present? && fdcome.size == 2 &&
            fdend.present? && fdend.size == 2
          @ground_histories = @ground_histories.
            where('extract(month from come_date) = ? AND extract(year from come_date) = ? AND ' +
              'extract(month from end_date) = ? AND extract(year from end_date) = ?',
              fdcome[0], fdcome[1], fdend[0], fdend[1])
        else
          @ground_histories = @ground_histories.
            where('extract(month from come_date) = ? AND extract(year from come_date) = ? AND ' +
              ' end_date is null', fdcome[0], fdcome[1])
        end
    elsif params[:come_date].present?
        # filter_date format: m/yyyy
        fd = params[:come_date].split("/")
        if fd.present? && fd.size == 2
          @ground_histories = @ground_histories.
            where('extract(month from come_date) = ? AND extract(year from come_date) = ?', fd[0], fd[1])
        end
    elsif params[:end_date].present?
        # filter_date format: m/yyyy
        fd = params[:end_date].split("/")
        if fd.present? && fd.size == 2
          @ground_histories = @ground_histories.
            where('extract(month from end_date) = ? AND extract(year from end_date) = ?', fd[0], fd[1])
        elsif
          @ground_histories = @ground_histories.where('end_date is null')
        end
    end

    respond_to do |format|
      format.html {}
      format.js {}
      format.xls {
        filename = "History-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
          send_data(GroundHistory.all.order(:id).to_xls(:only => GroundHistory::HEADER_COLUMNS,
            :header_columns => GroundHistory::HEADERS),
            type: "text/xls; charset=utf-8; header=present",
            filename: filename
          )
      }
      format.json { render json: @ground_histories }
    end
  end

  private
    def sort_column
      GroundHistory.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
