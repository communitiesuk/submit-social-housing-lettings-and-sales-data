module Forms
  module BulkUploadLettings
    class Template
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :ordered_template, :boolean
      attribute :year, :integer
      attribute :needstype, :integer

      validates :ordered_template, presence: true

      def view_path
        "bulk_upload_lettings_logs/forms/template"
      end

      def options
        [
          OpenStruct.new(id: true, name: "Legacy-style template"),
          OpenStruct.new(id: false, name: "New-style template"),
        ]
      end

      def back_path
        page_id = year == 2022 ? "needstype" : "prepare-your-file"
        bulk_upload_lettings_log_path(id: page_id, form: { year:, needstype: })
      end

      def next_path
        bulk_upload_lettings_log_path(id: "upload-your-file", form: { year:, needstype:, ordered_template: })
      end

      def save!
        true
      end

      def year_combo
        "#{year}/#{year + 1 - 2000}"
      end
    end
  end
end
