module Forms
  module BulkUploadForm
    class CheckingFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :log_type
      attribute :year, :integer
      attribute :organisation_id, :integer

      def view_path
        "bulk_upload_#{log_type}_logs/forms/checking_file"
      end

      def back_path
        if organisation_id.present?
          send("#{log_type}_logs_organisation_path", organisation_id)
        else
          send("bulk_upload_#{log_type}_log_path", id: "start")
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
