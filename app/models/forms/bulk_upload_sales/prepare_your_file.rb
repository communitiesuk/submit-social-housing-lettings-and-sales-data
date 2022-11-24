module Forms
  module BulkUploadSales
    class PrepareYourFile
      include ActiveModel::Model

      attr_accessor :year

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

      def in_crossover_period?
        FormHandler.instance.forms.values.any?(&:in_crossover_period?)
      end
    end
  end
end
