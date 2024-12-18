module Forms
  module BulkUploadForm
    class Guidance
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers
      include CollectionTimeHelper

      attribute :log_type
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
          send("bulk_upload_#{log_type}_log_path", id: "prepare-your-file", form: { year:, organisation_id: }.compact)
        when "home"
          root_path
        else
          guidance_path
        end
      end

      def lettings_template_path
        Forms::BulkUploadForm::PrepareYourFile.new(year:, log_type: "lettings").template_path
      end

      def lettings_specification_path
        Forms::BulkUploadForm::PrepareYourFile.new(year:, log_type: "lettings").specification_path
      end

      def sales_template_path
        Forms::BulkUploadForm::PrepareYourFile.new(year:, log_type: "sales").template_path
      end

      def sales_specification_path
        Forms::BulkUploadForm::PrepareYourFile.new(year:, log_type: "sales").specification_path
      end
    end
  end
end
