require "shellwords"

module Forms
  module BulkUploadLettings
    class UploadYourFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer
      attribute :file
      attribute :current_user

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

      def save!
        bulk_upload = BulkUpload.create!(
          user: current_user,
          log_type: BulkUpload.log_types[:lettings],
          year:,
        )

        if upload_enabled?
          storage_service.write_file(bulk_upload.identifier, File.read(file.path))
        end

        true
      end

    private

      def upload_enabled?
        !Rails.env.development?
      end

      def storage_service
        @storage_service ||= Storage::S3Service.new(Configuration::PaasConfigurationService.new, ENV["CSV_BUCKET"])
      end

      def validate_file_is_csv
        return unless file

        argv = %W[file --mime-type -- #{file.path}]
        output = `#{argv.shelljoin}`

        unless output.include?("text/csv")
          errors.add(:file, :not_csv)
        end
      end
    end
  end
end
