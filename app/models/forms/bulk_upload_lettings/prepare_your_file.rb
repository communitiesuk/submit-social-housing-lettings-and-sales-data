module Forms
  module BulkUploadLettings
    class PrepareYourFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer
      attribute :needstype, :integer
      attribute :organisation_id, :integer

      def view_path
        case year
        when 2023
          "bulk_upload_lettings_logs/forms/prepare_your_file_2023"
        when 2024
          "bulk_upload_lettings_logs/forms/prepare_your_file_2024"
        end
      end

      def back_path
        if have_choice_of_year?
          Rails.application.routes.url_helpers.bulk_upload_lettings_log_path(id: "year", form: { year:, organisation_id: }.compact)
        elsif organisation_id.present?
          lettings_logs_organisation_path(organisation_id)
        else
          Rails.application.routes.url_helpers.lettings_logs_path
        end
      end

      def next_path
        bulk_upload_lettings_log_path(id: "upload-your-file", form: { year:, needstype:, organisation_id: }.compact)
      end

      def template_path
        download_mandatory_collection_resource_path(year:, log_type: "lettings", resource_type: "bulk_upload_template")
      end

      def specification_path
        download_mandatory_collection_resource_path(year:, log_type: "lettings", resource_type: "bulk_upload_specification")
      end

      def year_combo
        "#{year}/#{year + 1 - 2000}"
      end

      def save!
        true
      end

    private

      def have_choice_of_year?
        return true if FeatureToggle.allow_future_form_use?

        FormHandler.instance.lettings_in_crossover_period?
      end
    end
  end
end
