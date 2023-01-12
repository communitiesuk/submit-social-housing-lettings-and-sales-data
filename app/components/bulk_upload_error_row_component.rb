class BulkUploadErrorRowComponent < ViewComponent::Base
  attr_reader :bulk_upload_errors

  def initialize(bulk_upload_errors:)
    @bulk_upload_errors = bulk_upload_errors

    super
  end

  def row
    bulk_upload_errors.first.row
  end

  def tenant_code
    bulk_upload_errors.first.tenant_code
  end

  def purchaser_code
    bulk_upload_errors.first.purchaser_code
  end

  def property_ref
    bulk_upload_errors.first.property_ref
  end

  def question_for_field(field)
    case bulk_upload.log_type
    when "lettings"
      BulkUpload::Lettings::Validator.question_for_field(field.to_sym)
    when "sales"
      BulkUpload::Sales::Validator.question_for_field(field.to_sym)
    else
      "Unknown question"
    end
  end

  def bulk_upload
    bulk_upload_errors.first.bulk_upload
  end

  def lettings?
    bulk_upload.log_type == "lettings"
  end

  def sales?
    bulk_upload.log_type == "sales"
  end
end
