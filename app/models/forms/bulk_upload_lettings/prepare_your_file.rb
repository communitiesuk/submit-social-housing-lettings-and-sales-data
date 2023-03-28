module Forms
  module BulkUploadLettings
    class PrepareYourFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer
      attribute :needstype, :integer

      def view_path
        "bulk_upload_lettings_logs/forms/prepare_your_file"
      end

      def back_path
        if in_crossover_period?
          Rails.application.routes.url_helpers.bulk_upload_lettings_log_path(id: "year", form: { year: })
        else
          Rails.application.routes.url_helpers.lettings_logs_path
        end
      end

      def next_path
        page_id = year == 2022 ? "needstype" : "upload-your-file"
        bulk_upload_lettings_log_path(id: page_id, form: { year:, needstype: })
      end

      def old_template_path
        "/files/bulk-upload-lettings-template-2022-23.xlsx"
      end

      def template_path
        case year
        when 2022
          "/files/bulk-upload-lettings-template-2022-23.xlsx"
        when 2023
          "/files/bulk-upload-lettings-template-2023-24.xlsx"
        end
      end

      def specification_path
        case year
        when 2022
          "/files/bulk-upload-lettings-specification-2022-23.xlsx"
        when 2023
          "/files/bulk-upload-lettings-specification-2023-24.xlsx"
        end
      end

      def year_combo
        "#{year}/#{year + 1 - 2000}"
      end

      def inset_text
        if year == 2022
          '<p class="govuk-inset-text">For 2022/23 data, you cannot have a CSV file with both general needs logs and supported housing logs. These must be in separate files.</p>'.html_safe
        end
      end

      def save!
        true
      end

    private

      def in_crossover_period?
        return true if FeatureToggle.force_crossover?

        FormHandler.instance.lettings_in_crossover_period?
      end
    end
  end
end
