module Forms
  module BulkUploadSalesSoftValidationsCheck
    class Confirm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload

      def view_path
        "bulk_upload_sales_soft_validations_check/confirm"
      end

      def back_path
        page_bulk_upload_sales_soft_validations_check_path(bulk_upload, page: "confirm-soft-errors")
      end

      def next_path
        sales_logs_path
      end

      def save!
        ApplicationRecord.transaction do
          processor = BulkUpload::Processor.new(bulk_upload:)
          processor.approve_and_confirm_soft_validations

          bulk_upload.update!(choice: "bulk-confirm-soft-validations")
        end

        true
      end

      def preflight_valid?
        bulk_upload.choice != "completed" && bulk_upload.choice != "bulk-confirm-soft-validations" && bulk_upload.choice != "create-fix-inline"
      end

      def preflight_redirect
        case bulk_upload.choice
        when "bulk-confirm-soft-validations"
          page_bulk_upload_sales_soft_validations_check_path(bulk_upload, :chosen)
        when "create-fix-inline"
          page_bulk_upload_sales_resume_path(bulk_upload, :chosen)
        when "completed"
          resume_bulk_upload_lettings_result_path(bulk_upload.id)
        end
      end
    end
  end
end
