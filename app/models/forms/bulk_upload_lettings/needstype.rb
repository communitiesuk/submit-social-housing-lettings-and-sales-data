module Forms
  module BulkUploadLettings
    class Needstype
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :needstype, :integer
      attribute :year, :integer

      validates :needstype, presence: true

      def view_path
        "bulk_upload_lettings_logs/forms/needstype"
      end

      def options
        [OpenStruct.new(id: 1, name: "General needs"), OpenStruct.new(id: 2, name: "Supported housing")]
      end

      def back_path
        bulk_upload_lettings_log_path(id: "prepare-your-file", form: { year:, needstype: })
      end

      def next_path
        bulk_upload_lettings_log_path(id: "upload-your-file", form: { year:, needstype: })
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
