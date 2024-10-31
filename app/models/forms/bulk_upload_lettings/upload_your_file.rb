require "shellwords"

module Forms
  module BulkUploadLettings
    class UploadYourFile
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer
      attribute :needstype, :integer
      attribute :file
      attribute :current_user
      attribute :organisation_id, :integer

      validates :file, presence: true
      validate :validate_file_is_csv
      validate :validate_file_size

      def view_path
        "bulk_upload_lettings_logs/forms/upload_your_file"
      end

      def back_path
        bulk_upload_lettings_log_path(id: "prepare-your-file", form: { year:, needstype:, organisation_id: }.compact)
      end

      def year_combo
        "#{year} to #{year + 1}"
      end

      def next_path
        bulk_upload_lettings_log_path(id: "checking-file", form: { year:, organisation_id: }.compact)
      end

      def save!
        bulk_upload = BulkUpload.create!(
          user: current_user,
          log_type: BulkUpload.log_types[:lettings],
          year:,
          needstype:,
          filename: file.original_filename,
          organisation_id: (organisation_id if current_user.support?) || current_user.organisation_id,
        )

        storage_service.write_file(bulk_upload.identifier, File.read(file.path))

        ProcessBulkUploadJob.perform_later(bulk_upload:)

        true
      end

    private

      def upload_enabled?
        FeatureToggle.upload_enabled?
      end

      def storage_service
        @storage_service ||= if upload_enabled?
                               Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
                             else
                               Storage::LocalDiskService.new
                             end
      end

      def validate_file_is_csv
        return unless file

        argv = %W[file --brief --mime-type -- #{file.path}]
        output = `#{argv.shelljoin}`

        unless output.match?(/text\/csv|text\/plain/)
          errors.add(:file, :not_csv)
        end
      end

      MAX_FILE_SIZE = 10.megabytes

      def validate_file_size
        return unless file

        if file.size > MAX_FILE_SIZE
          errors.add(:file, :file_too_large)
        end
      end
    end
  end
end
