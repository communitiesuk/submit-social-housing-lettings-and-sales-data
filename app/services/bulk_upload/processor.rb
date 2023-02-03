class BulkUpload::Processor
  attr_reader :bulk_upload

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload
  end

  def call
    download

    return send_failure_mail if validator.invalid?

    validator.call
    create_logs if validator.create_logs?
    send_success_mail
  rescue StandardError => e
    Sentry.capture_exception(e)
    send_failure_mail
  ensure
    downloader.delete_local_file!
  end

private

  def send_success_mail
    if validator.create_logs? && bulk_upload.logs.group(:status).count.keys == %w[completed]
      BulkUploadMailer.send_bulk_upload_complete_mail(user:, bulk_upload:).deliver_later
    end
  end

  def send_failure_mail
    BulkUploadMailer.send_bulk_upload_failed_service_error_mail(bulk_upload:).deliver_later
  end

  def user
    bulk_upload.user
  end

  def create_logs
    log_creator_class.new(
      bulk_upload:,
      path: downloader.path,
    ).call
  end

  def log_creator_class
    case bulk_upload.log_type
    when "lettings"
      BulkUpload::Lettings::LogCreator
    when "sales"
      BulkUpload::Sales::LogCreator
    else
      raise "Log creator not found for #{bulk_upload.log_type}"
    end
  end

  def downloader
    @downloader ||= BulkUpload::Downloader.new(bulk_upload:)
  end

  def download
    downloader.call
  end

  def validator
    @validator ||= validator_class.new(
      bulk_upload:,
      path: downloader.path,
    )
  end

  def validator_class
    case bulk_upload.log_type
    when "lettings"
      BulkUpload::Lettings::Validator
    when "sales"
      BulkUpload::Sales::Validator
    else
      raise "Validator not found for #{bulk_upload.log_type}"
    end
  end
end
