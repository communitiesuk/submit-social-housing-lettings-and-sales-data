module Forms
  module BulkUploadSales
    class CheckingFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer
      attribute :organisation_id, :integer

      def view_path
        "bulk_upload_sales_logs/forms/checking_file"
      end

      def back_path
        if organisation_id.present?
          sales_logs_organisation_path(organisation_id)
        else
          bulk_upload_sales_log_path(id: "start")
        end
      end

      def year_combo
        "#{year} to #{year + 1}"
      end

      def save!
        true
      end
    end
  end
end
