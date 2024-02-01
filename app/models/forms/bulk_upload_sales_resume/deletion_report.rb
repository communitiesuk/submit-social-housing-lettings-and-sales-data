module Forms
  module BulkUploadSalesResume
    class DeletionReport
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload

      def view_path
        "bulk_upload_sales_resume/deletion_report"
      end

      def preflight_valid?
        bulk_upload.choice != "create-fix-inline" && bulk_upload.choice != "bulk-confirm-soft-validations"
      end

      def preflight_redirect
        case bulk_upload.choice
        when "create-fix-inline"
          page_bulk_upload_sales_resume_path(bulk_upload, :chosen)
        when "bulk-confirm-soft-validations"
          page_bulk_upload_sales_soft_validations_check_path(bulk_upload, :chosen)
        end
      end
    end
  end
end
