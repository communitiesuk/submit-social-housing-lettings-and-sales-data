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

  def tenant_code_html
    return if tenant_code.blank?

    content_tag :span, class: "govuk-!-margin-left-3" do
      "Tenant code: #{tenant_code}"
    end
  end

  def purchaser_code
    bulk_upload_errors.first.purchaser_code
  end

  def purchaser_code_html
    return if purchaser_code.blank?

    content_tag :span, class: "govuk-!-margin-left-3" do
      "Purchaser code: #{purchaser_code}"
    end
  end

  def property_ref
    bulk_upload_errors.first.property_ref
  end

  def property_ref_html
    return if property_ref.blank?

    content_tag :span, class: "govuk-!-margin-left-3" do
      "Property reference: #{property_ref}"
    end
  end

  def question_for_field(field)
    bulk_upload.prefix_namespace::RowParser.question_for_field(field.to_sym)
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

  def row_classes(index, errors_size)
    row_class = "grouped-rows"
    row_class += " first-row" if index.zero?
    row_class += " last-row" if index == errors_size - 1
    row_class
  end

  def cell_classes(group_index, total_groups)
    cell_class = "govuk-!-font-weight-bold govuk-!-width-one-half"
    cell_class += " grouped-multirow-cell" unless group_index == total_groups - 1
    cell_class
  end
end
