module Forms
  module BulkUploadSales
    class UploadYourFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer

      def view_path
        "bulk_upload_sales_logs/forms/upload_your_file"
      end

      def back_path
        bulk_upload_sales_log_path(id: "prepare-your-file", form: { year: })
      end
    end
  end
end
