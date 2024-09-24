class BulkUploadSummaryComponent < ViewComponent::Base
  attr_reader :bulk_upload

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload
    @bulk_upload_errors = bulk_upload.bulk_upload_errors
    super
  end

  def upload_status
    helpers.status_tag(bulk_upload.status, ["app-tag--small govuk-!-font-weight-regular no-max-width"])
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

  def formatted_count_text(count, singular_text, plural_text = nil)
    return if count.nil? || count <= 0

    text = count > 1 ? (plural_text || singular_text.pluralize(count)) : singular_text
    content_tag(:p, class: "govuk-!-font-size-16 govuk-!-margin-bottom-1") do
      concat(content_tag(:strong, count))
      concat(" #{text}")
    end
  end

  def counts(*counts_with_texts)
    counts_with_texts.map { |count, singular_text, plural_text|
      formatted_count_text(count, singular_text, plural_text) if count.present?
    }.compact.join("").html_safe
  end

  def download_file_link(controller, bulk_upload)
    case controller.controller_name
    when "lettings_logs"
      download_lettings_file_link(bulk_upload)
    when "sales_logs"
      download_sales_file_link(bulk_upload)
    else
      raise "Download file link not found for bulk upload"
    end
  end

  def download_lettings_file_link(bulk_upload)
    link_to "Download file", download_lettings_bulk_upload_path(bulk_upload), class: "govuk-link govuk-!-margin-right-2"
  end

  def download_sales_file_link(bulk_upload)
    link_to "Download file", download_sales_bulk_upload_path(bulk_upload), class: "govuk-link govuk-!-margin-right-2"
  end

  def view_error_report_link(controller, bulk_upload)
    return nil if %w[errors_fixed_in_service logs_uploaded_with_errors logs_uploaded_no_errors].include?(bulk_upload.status.to_s)

    case controller.controller_name
    when "lettings_logs"
      return link_to "View error report", summary_bulk_upload_lettings_result_url(bulk_upload), class: "govuk-link" if %w[important_errors].include?(bulk_upload.status.to_s)
      link_to "View error report", bulk_upload_lettings_result_path(bulk_upload.id), class: "govuk-link"
    when "sales_logs"
      return link_to "View error report", summary_bulk_upload_sales_result_url(bulk_upload), class: "govuk-link" if %w[important_errors].include?(bulk_upload.status.to_s)
      link_to "View error report", bulk_upload_sales_result_path(bulk_upload.id), class: "govuk-link"
    else
      raise "Error report link not found for bulk upload"
    end
  end

  def view_logs_link(controller, bulk_upload)
    return nil if %w[errors_fixed_in_service logs_uploaded_no_errors].include?(bulk_upload.status.to_s)

    case controller.controller_name
    when "lettings_logs"
      return nil unless %w[errors_fixed_in_service logs_uploaded_with_errors logs_uploaded_no_errors].include?(bulk_upload.status.to_s)
      link_to "View logs", "/lettings-logs?bulk_upload_id%5B%5D=#{bulk_upload.id}", class: "govuk-link"
    when "sales_logs"
      return nil unless %w[errors_fixed_in_service logs_uploaded_with_errors logs_uploaded_no_errors].include?(bulk_upload.status.to_s)
      link_to "View logs", "/sales-logs?bulk_upload_id%5B%5D=#{bulk_upload.id}", class: "govuk-link"
    else
      raise "View logs link not found for bulk upload"
    end
  end
end
