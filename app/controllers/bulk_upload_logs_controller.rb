class BulkUploadLogsController < ApplicationController
  before_action :authenticate_user!

  def start
    if in_crossover_period?
      redirect_to bulk_upload_path(id: "year")
    else
      redirect_to bulk_upload_path(id: "prepare-your-file")
    end
  end

private

  def in_crossover_period?
    FormHandler.instance.forms.values.any?(&:in_crossover_period?)
  end

  def bulk_upload_path(id:)
    case log_type
    when "lettings"
      bulk_upload_lettings_log_path(id:)
    when "sales"
      bulk_upload_sales_log_path(id:)
    end
  end

  def log_type
    case request.path.split("/")[1]
    when "lettings-logs"
      "lettings"
    when "sales-logs"
      "sales"
    else
      raise "Log type not handled"
    end
  end
end
