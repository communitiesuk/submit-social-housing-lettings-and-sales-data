module Forms
  module BulkUploadSales
    class Guidance
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers
      include CollectionTimeHelper

      attribute :year, :integer
      attribute :referrer
      attribute :organisation_id, :integer

      def initialize(params)
        super(params)

        self.year = current_collection_start_year if year.nil?
      end

      def view_path
        "bulk_upload_shared/guidance"
      end

      def back_path
        case referrer
        when "prepare-your-file"
          bulk_upload_sales_log_path(id: "prepare-your-file", form: { year:, organisation_id: }.compact)
        when "home"
          root_path
        else
          guidance_path
        end
      end

      def lettings_template_path
        Forms::BulkUploadLettings::PrepareYourFile.new(year:).template_path
      end

      def lettings_specification_path
        Forms::BulkUploadLettings::PrepareYourFile.new(year:).specification_path
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
