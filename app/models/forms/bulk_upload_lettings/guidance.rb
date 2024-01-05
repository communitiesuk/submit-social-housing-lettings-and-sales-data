module Forms
  module BulkUploadLettings
    class Guidance
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer

      def view_path
        "bulk_upload_shared/guidance"
      end

      def back_path
        bulk_upload_lettings_log_path(id: "prepare-your-file", form: { year: })
      end

      def lettings_legacy_template_path
        Forms::BulkUploadLettings::PrepareYourFile.new.legacy_template_path
      end

      def lettings_template_path
        Forms::BulkUploadLettings::PrepareYourFile.new(year:).template_path
      end

      def lettings_specification_path
        Forms::BulkUploadLettings::PrepareYourFile.new(year:).specification_path
      end

      def sales_legacy_template_path
        Forms::BulkUploadSales::PrepareYourFile.new.legacy_template_path
      end

      def sales_template_path
        Forms::BulkUploadSales::PrepareYourFile.new(year:).template_path
      end

      def sales_specification_path
        Forms::BulkUploadSales::PrepareYourFile.new(year:).specification_path
      end
    end
  end
end
