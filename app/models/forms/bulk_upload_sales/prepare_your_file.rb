module Forms
  module BulkUploadSales
    class PrepareYourFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer

      def view_path
        "bulk_upload_sales_logs/forms/prepare_your_file"
      end

      def back_path
        if in_crossover_period?
          Rails.application.routes.url_helpers.bulk_upload_sales_log_path(id: "year", form: { year: })
        else
          Rails.application.routes.url_helpers.sales_logs_path
        end
      end

      def next_path
        bulk_upload_sales_log_path(id: "upload-your-file", form: { year: })
      end

      def template_path
        "/files/bulk-upload-sales-template-2023-24.xlsx"
      end

      def old_template_path
        "/files/bulk-upload-sales-template-2022-23.xlsx"
      end

      def specification_path
        if year <= 2022
          "/files/bulk-upload-sales-specification-2022-23.xlsx"
        else
          "/files/bulk-upload-sales-specification-2023-24.xlsx"
        end
      end

      def specification_path
        "/files/bulk-upload-sales-specification-2022-23.xlsx"
      end

      def year_combo
        "#{year}/#{year + 1 - 2000}"
      end

      def save!
        true
      end

    private

      def in_crossover_period?
        FormHandler.instance.sales_in_crossover_period?
      end
    end
  end
end
