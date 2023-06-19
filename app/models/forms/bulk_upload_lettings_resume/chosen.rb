module Forms
  module BulkUploadLettingsResume
    class Chosen
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload

      def view_path
        "bulk_upload_lettings_resume/chosen"
      end

      def back_path
        lettings_logs_path
      end

      def next_path
        lettings_logs_path
      end

      def save!
        true
      end

      def preflight_valid?
        true
      end
    end
  end
end
