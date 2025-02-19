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
    @bulk_upload_errors.where(category: [nil, "", "not_answered"]).count
  end

  def potential_errors_count
    @bulk_upload_errors.where(category: "soft_validation").count
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

  def download_file_link(bulk_upload)
    send("download_#{bulk_upload.log_type}_file_link", bulk_upload)
  end

  def download_lettings_file_link(bulk_upload)
    govuk_link_to "Download file", download_lettings_bulk_upload_path(bulk_upload), class: "govuk-link govuk-!-margin-right-2"
  end

  def download_sales_file_link(bulk_upload)
    govuk_link_to "Download file", download_sales_bulk_upload_path(bulk_upload), class: "govuk-link govuk-!-margin-right-2"
  end

  def view_error_report_link(bulk_upload)
    status = bulk_upload.status.to_s
    return unless %w[important_errors critical_errors potential_errors].include?(status)

    path = if status == "important_errors"
             "summary_bulk_upload_#{bulk_upload.log_type}_result_url"
           else
             "bulk_upload_#{bulk_upload.log_type}_result_path"
           end

    govuk_link_to "View error report", send(path, bulk_upload), class: "govuk-link"
  end

  def view_logs_link(bulk_upload)
    return unless bulk_upload.status.to_s == "logs_uploaded_with_errors"

    govuk_link_to "View logs with errors", send("#{bulk_upload.log_type}_logs_path", bulk_upload_id: [bulk_upload.id]), class: "govuk-link"
  end
end
