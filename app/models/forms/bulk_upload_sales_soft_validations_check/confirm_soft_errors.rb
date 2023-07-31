module Forms
  module BulkUploadSalesSoftValidationsCheck
    class ConfirmSoftErrors
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload
      attribute :confirm_soft_errors, :string

      validates :confirm_soft_errors, presence: true

      def options
        [
          OpenStruct.new(id: "yes", name: "Yes, these fields are correct"),
          OpenStruct.new(id: "no", name: "No, there are errors"),
        ]
      end

      def view_path
        "bulk_upload_sales_soft_validations_check/confirm_soft_errors"
      end

      def next_path
        case confirm_soft_errors
        when "no"
          page_bulk_upload_sales_resume_path(bulk_upload, page: "fix-choice", soft_errors_only: true)
        when "yes"
          page_bulk_upload_sales_soft_validations_check_path(bulk_upload, page: "confirm")
        else
          raise "invalid choice"
        end
      end

      def save!
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
