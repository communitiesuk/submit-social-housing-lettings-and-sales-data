module BulkUploadHelper
  def bulk_upload_title(controller)
    case controller.controller_name
    when "lettings_logs"
      "Lettings bulk uploads"
    when "sales_logs"
      "Sales bulk uploads"
    else
      "Bulk uploads"
    end
  end
end
