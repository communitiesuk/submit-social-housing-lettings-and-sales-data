module Forms
  module BulkUploadSales
    class Guidance
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer

      def view_path
        "bulk_upload_shared/guidance"
      end

      def back_path
        bulk_upload_sales_log_path(id: "prepare-your-file", form: { year: })
      end

      def template_path
        Forms::BulkUploadSales::PrepareYourFile.new(year:).template_path
      end

      def specification_path
        Forms::BulkUploadSales::PrepareYourFile.new(year:).specification_path
      end
    end
  end
end
