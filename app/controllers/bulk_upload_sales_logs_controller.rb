class BulkUploadSalesLogsController < ApplicationController
  before_action :authenticate_user!

  def start
    if in_crossover_period?
      redirect_to bulk_upload_sales_log_path(id: "year")
    else
      redirect_to bulk_upload_sales_log_path(id: "prepare-your-file")
    end
  end

private

  def in_crossover_period?
    FormHandler.instance.forms.values.any?(&:in_crossover_period?)
  end
end
