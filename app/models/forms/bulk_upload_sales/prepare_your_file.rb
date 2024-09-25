module Forms
  module BulkUploadSales
    class PrepareYourFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer
      attribute :organisation_id, :integer

      def view_path
        case year
        when 2023
          "bulk_upload_sales_logs/forms/prepare_your_file_2023"
        when 2024
          "bulk_upload_sales_logs/forms/prepare_your_file_2024"
        end
      end

      def back_path
        if have_choice_of_year?
          Rails.application.routes.url_helpers.bulk_upload_sales_log_path(id: "year", form: { year: }.compact)
        elsif organisation_id.present?
          sales_logs_organisation_path(organisation_id)
        else
          Rails.application.routes.url_helpers.sales_logs_path
        end
      end

      def next_path
        bulk_upload_sales_log_path(id: "upload-your-file", form: { year:, organisation_id: }.compact)
      end

      def legacy_template_path
        case year
        when 2023
          "/files/bulk-upload-sales-legacy-template-2023-24.xlsx"
        end
      end

      def template_path
        case year
        when 2023
          "/files/bulk-upload-sales-template-2023-24.xlsx"
        when 2024
          "/files/bulk-upload-sales-template-2024-25.xlsx"
        end
      end

      def specification_path
        case year
        when 2023
          "/files/bulk-upload-sales-specification-2023-24.xlsx"
        when 2024
          "/files/bulk-upload-sales-specification-2024-25.xlsx"
        end
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

        FormHandler.instance.sales_in_crossover_period?
      end
    end
  end
end
