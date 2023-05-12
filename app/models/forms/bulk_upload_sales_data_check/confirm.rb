module Forms
  module BulkUploadSalesDataCheck
    class Confirm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload

      def view_path
        "bulk_upload_sales_data_check/confirm"
      end

      def back_path
        page_bulk_upload_sales_data_check_path(bulk_upload, page: "soft-errors-valid")
      end

      def next_path
        sales_logs_path
      end

      def save!
        processor = BulkUpload::Processor.new(bulk_upload:)
        processor.approve_and_confirm_soft_validations

        true
      end
    end
  end
end
