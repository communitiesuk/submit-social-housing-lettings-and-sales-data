module Forms
  module BulkUploadLettings
    class Year
      include ActiveModel::Model

      attr_accessor :year

      validates :year, presence: true

      def view_path
        "bulk_upload_lettings_logs/forms/year"
      end

      def options
        [
          OpenStruct.new(id: "2022", name: "2022/2023"),
          OpenStruct.new(id: "2021", name: "2021/2022"),
        ]
      end

      def back_path
        Rails.application.routes.url_helpers.lettings_logs_path
      end
    end
  end
end
