module Forms
  module BulkUploadResume
    class Confirm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :log_type
      attribute :bulk_upload

      def view_path
        "bulk_upload_#{log_type}_resume/confirm"
      end

      def back_path
        send("page_bulk_upload_#{log_type}_resume_path", bulk_upload, page: "fix-choice")
      end

      def next_path
        send("resume_bulk_upload_#{log_type}_result_path", bulk_upload)
      end

      def error_report_path
        if BulkUploadErrorSummaryTableComponent.new(bulk_upload:).errors?
          send("summary_bulk_upload_#{log_type}_result_path", bulk_upload)
        else
          send("bulk_upload_#{log_type}_result_path", bulk_upload)
        end
      end

      def save!
        ApplicationRecord.transaction do
          processor = BulkUpload::Processor.new(bulk_upload:)
          processor.approve

          bulk_upload.update!(choice: "create-fix-inline")
        end

        true
      end

      def preflight_valid?
        bulk_upload.choice != "create-fix-inline" && bulk_upload.choice != "bulk-confirm-soft-validations"
      end

      def preflight_redirect
        case bulk_upload.choice
        when "create-fix-inline"
          send("page_bulk_upload_#{log_type}_resume_path", bulk_upload, :chosen)
        when "bulk-confirm-soft-validations"
          send("page_bulk_upload_#{log_type}_soft_validations_check_path", bulk_upload, :chosen)
        end
      end
    end
  end
end
