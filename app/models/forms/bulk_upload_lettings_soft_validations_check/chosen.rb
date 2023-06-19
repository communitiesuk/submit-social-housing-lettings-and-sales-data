module Forms
  module BulkUploadLettingsSoftValidationsCheck
    class Chosen
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload

      def view_path
        "bulk_upload_lettings_soft_validations_check/chosen"
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
