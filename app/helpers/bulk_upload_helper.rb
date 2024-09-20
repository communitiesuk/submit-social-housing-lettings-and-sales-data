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

  def bulk_upload_details(bulk_upload)
    content_tag(:span) do
      concat("Uploaded by: #{bulk_upload.user.name} (#{bulk_upload.user.email})<br>".html_safe)
      concat("Uploading organisation: #{bulk_upload.user.organisation.name}<br>".html_safe)
      concat("Time of upload: #{bulk_upload.created_at.to_formatted_s(:govuk_date)}".html_safe)
    end
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

  def view_error_report_link
    link_to "View error report", "#", class: "govuk-link"
  def download_lettings_file_link(bulk_upload)
    link_to "Download file", download_lettings_bulk_upload_path(bulk_upload), class: "govuk-link govuk-!-margin-right-2"
  end

  def download_sales_file_link(bulk_upload)
    link_to "Download file", download_sales_bulk_upload_path(bulk_upload), class: "govuk-link govuk-!-margin-right-2"
  end

  def view_error_report_link(bulk_upload)
    link_to "View error report", "/lettings-logs/bulk-upload-resume/#{bulk_upload.id}/start", class: "govuk-link"
  end

  def view_logs_link(bulk_upload)
    link_to "View logs", "#", class: "govuk-link"
  end

end
