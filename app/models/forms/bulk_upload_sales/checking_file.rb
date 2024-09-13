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
          lettings_logs_organisation_path(organisation_id)
        else
          bulk_upload_sales_log_path(id: "start", form: { organisation_id: organisation_id }.compact)
        end
      end

      def year_combo
        "#{year}/#{year + 1 - 2000}"
      end

      def save!
        true
      end
    end
  end
end
