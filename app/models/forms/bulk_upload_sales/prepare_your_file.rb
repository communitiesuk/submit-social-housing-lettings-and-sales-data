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
        "/files/bulk-upload-sales-template-v1.xlsx"
      end

      def year_combo
        "#{year}/#{year + 1 - 2000}"
      end

    private

      def in_crossover_period?
        FormHandler.instance.forms.values.any?(&:in_crossover_period?)
      end
    end
  end
end
