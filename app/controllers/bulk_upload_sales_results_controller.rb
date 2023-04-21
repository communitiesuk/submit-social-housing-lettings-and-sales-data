class BulkUploadSalesResultsController < ApplicationController
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def show
    @bulk_upload = current_user.bulk_uploads.sales.find(params[:id])
  end

  def resume
    @bulk_upload = current_user.bulk_uploads.sales.find(params[:id])

    if @bulk_upload.sales_logs.in_progress.count.positive?
      set_bulk_upload_logs_filters

      redirect_to(sales_logs_path(bulk_upload_id: [@bulk_upload.id]))
    else
      reset_logs_filters
    end
  end

  def summary
    @bulk_upload = current_user.bulk_uploads.sales.find(params[:id])
  end
end
