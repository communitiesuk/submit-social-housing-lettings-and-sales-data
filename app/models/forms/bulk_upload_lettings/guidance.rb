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

      def old_template_path
        Forms::BulkUploadLettings::PrepareYourFile.new.old_template_path
      end

      def template_path
        Forms::BulkUploadLettings::PrepareYourFile.new(year:).template_path
      end

      def specification_path
        Forms::BulkUploadLettings::PrepareYourFile.new(year:).specification_path
      end
    end
  end
end
