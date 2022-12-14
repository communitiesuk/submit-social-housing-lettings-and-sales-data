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

  def property_ref
    bulk_upload_errors.first.property_ref
  end

  def question_for_field(field)
    BulkUpload::LettingsValidator.question_for_field(field.to_sym)
  end
end
