module BulkUploadHelper
  def bulk_upload_title(controller)
    case controller.controller_name
    when "lettings_logs"
      "Lettings bulk uploads"
    when "sales_logs"
      "Sales bulk uploads"
    else
      "Bulk uploads"
    end
  end

  def bulk_upload_status(bulk_upload)
    validator = validator_class(bulk_upload).new(bulk_upload: bulk_upload, path: bulk_upload.file_path)

    if validator.invalid?
      "The bulk upload has failed due to validation errors."
    elsif validator.any_setup_errors?
      "The bulk upload has setup errors."
    elsif validator.soft_validation_errors_only?
      "The bulk upload has soft validation errors."
    elsif bulk_upload.logs.where.not(status_cache: %w[completed]).count.positive?
      "The bulk upload has created logs but some are incomplete."
    elsif bulk_upload.logs.group(:status_cache).count.keys == %w[completed]
      "The bulk upload has successfully completed."
    else
      "The bulk upload status is unknown."
    end
  end

private

  def validator_class(bulk_upload)
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
