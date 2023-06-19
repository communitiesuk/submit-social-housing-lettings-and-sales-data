module Forms
  module BulkUploadSalesSoftValidationsCheck
    class Chosen
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload

      def view_path
        "bulk_upload_sales_soft_validations_check/chosen"
      end

      def back_path
        sales_logs_path
      end

      def next_path
        sales_logs_path
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
