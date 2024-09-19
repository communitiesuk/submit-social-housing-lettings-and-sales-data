class BulkUploadSummaryComponent < ViewComponent::Base
  include BulkUploadHelper

  attr_reader :bulk_upload

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload
    @bulk_upload_errors = bulk_upload.bulk_upload_errors
    super
  end

  def upload_status
    helpers.status_tag("in_progress")
  end

  def setup_errors_count
    @bulk_upload_errors.where(category: "setup").count
  end

  def critical_errors_count
    @bulk_upload_errors.where(category: [nil, ""]).count
  end

  def potential_errors_count
    @bulk_upload_errors.where(category: "soft_validations").count
  end


end
