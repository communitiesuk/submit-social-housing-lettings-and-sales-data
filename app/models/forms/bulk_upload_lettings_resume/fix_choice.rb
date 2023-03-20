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
    end
  end
end
