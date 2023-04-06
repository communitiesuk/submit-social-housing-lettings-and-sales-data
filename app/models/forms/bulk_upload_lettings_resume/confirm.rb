module Forms
  module BulkUploadLettingsResume
    class Confirm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload

      def view_path
        "bulk_upload_lettings_resume/confirm"
      end

      def back_path
        page_bulk_upload_lettings_resume_path(bulk_upload, page: "fix-choice")
      end

      def next_path
        resume_bulk_upload_lettings_result_path(bulk_upload)
      end

      def save!
        processor = BulkUpload::Processor.new(bulk_upload:)
        processor.approve

        true
      end
    end
  end
end
