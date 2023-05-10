module Forms
  module BulkUploadLettingsDataCheck
    class Confirm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload

      def view_path
        "bulk_upload_lettings_data_check/confirm"
      end

      def back_path
        page_bulk_upload_lettings_data_check_path(bulk_upload, page: "soft-errors-valid")
      end

      def next_path
        page_bulk_upload_lettings_resume_path(bulk_upload, page: "fix-choice")
      end
    end
  end
end
