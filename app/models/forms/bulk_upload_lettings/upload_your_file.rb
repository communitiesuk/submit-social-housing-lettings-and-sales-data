module Forms
  module BulkUploadLettings
    class UploadYourFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer
      attribute :file

      validates :file, presence: true
      validate :validate_file_is_csv

      def view_path
        "bulk_upload_lettings_logs/forms/upload_your_file"
      end

      def back_path
        bulk_upload_lettings_log_path(id: "prepare-your-file", form: { year: })
      end

      def year_combo
        "#{year}/#{year + 1 - 2000}"
      end

      def next_path
        bulk_upload_lettings_log_path(id: "checking-file", form: { year: })
      end

    private

      def validate_file_is_csv
        return unless file

        unless FileMagic.new(FileMagic::MAGIC_MIME).file(file.path).include?("text/csv")
          errors.add(:file, :not_csv)
        end
      end
    end
  end
end
