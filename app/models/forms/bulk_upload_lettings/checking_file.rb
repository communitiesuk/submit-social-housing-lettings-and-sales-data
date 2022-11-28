module Forms
  module BulkUploadLettings
    class CheckingFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer

      def view_path
        "bulk_upload_lettings_logs/forms/checking_file"
      end

      def back_path
        bulk_upload_lettings_log_path(id: "start")
      end

      def year_combo
        "#{year}/#{year + 1 - 2000}"
      end
    end
  end
end
