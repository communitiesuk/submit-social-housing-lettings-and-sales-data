module Forms
  module BulkUploadLettingsResume
    class FixChoice
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload
      attribute :choice, :string

      validates :choice, presence: true,
                         inclusion: { in: %w[create-fix-inline upload-again] }

      def options
        [
          OpenStruct.new(id: "create-fix-inline", name: "Upload these logs and fix errors on CORE site"),
          OpenStruct.new(id: "upload-again", name: "Fix errors in the CSV and re-upload"),
        ]
      end

      def view_path
        "bulk_upload_lettings_resume/fix_choice"
      end

      def next_path
        case choice
        when "create-fix-inline"
          page_bulk_upload_lettings_resume_path(bulk_upload, page: "confirm")
        when "upload-again"
          if BulkUploadErrorSummaryTableComponent.new(bulk_upload:).errors?
            summary_bulk_upload_lettings_result_path(bulk_upload)
          else
            bulk_upload_lettings_result_path(bulk_upload)
          end
        else
          raise "invalid choice"
        end
      end

      def recommendation
        if BulkUploadErrorSummaryTableComponent.new(bulk_upload:).errors?
          "For this many errors we recommend to fix errors in the CSV and re-upload as you may be able to edit many fields at once in a CSV."
        else
          "For this many errors we recommend to upload logs and fix errors on site as you can easily see the questions and select the appropriate answer."
        end
      end

      def save!
        bulk_upload.update!(choice:) if choice == "upload-again"

        true
      end

      def preflight_valid?
        bulk_upload.choice != "create-fix-inline" && bulk_upload.choice != "bulk-confirm-soft-validations"
      end

      def preflight_redirect
        case bulk_upload.choice
        when "create-fix-inline"
          page_bulk_upload_lettings_resume_path(bulk_upload, :chosen)
        when "bulk-confirm-soft-validations"
          page_bulk_upload_lettings_soft_validations_check_path(bulk_upload, :chosen)
        end
      end
    end
  end
end
