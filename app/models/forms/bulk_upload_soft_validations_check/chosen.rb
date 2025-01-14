module Forms
  module BulkUploadSoftValidationsCheck
    class Chosen
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :log_type
      attribute :bulk_upload

      def view_path
        "bulk_upload_#{log_type}_soft_validations_check/chosen"
      end

      def back_path
        send("#{log_type}_logs_path")
      end

      def next_path
        send("#{log_type}_logs_path")
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
