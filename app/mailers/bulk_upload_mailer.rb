class BulkUploadMailer < NotifyMailer
  include ActionView::Helpers::TextHelper

  COMPLETE_TEMPLATE_ID = "83279578-c890-4168-838b-33c9cf0dc9f0".freeze
  FAILED_CSV_ERRORS_TEMPLATE_ID = "e27abcd4-5295-48c2-b127-e9ee4b781b75".freeze
  FAILED_FILE_SETUP_ERROR_TEMPLATE_ID = "24c9f4c7-96ad-470a-ba31-eb51b7cbafd9".freeze
  FAILED_SERVICE_ERROR_TEMPLATE_ID = "c3f6288c-7a74-4e77-99ee-6c4a0f6e125a".freeze
  HOW_FIX_UPLOAD_TEMPLATE_ID = "21a07b26-f625-4846-9f4d-39e30937aa24".freeze

  def send_how_fix_upload_mail(bulk_upload:)
    title = "We found #{pluralize(bulk_upload.bulk_upload_errors.count, 'error')} in your bulk upload"
    description = "There was a problem with your #{bulk_upload.year_combo} #{bulk_upload.log_type} data. Check the error report below to fix these errors."
    cta_link = start_bulk_upload_lettings_resume_url(bulk_upload)

    send_email(
      bulk_upload.user.email,
      HOW_FIX_UPLOAD_TEMPLATE_ID,
      {
        title:,
        filename: bulk_upload.filename,
        upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
        description:,
        cta_link:,
      },
    )
  end

  def send_bulk_upload_complete_mail(user:, bulk_upload:)
    url = if bulk_upload.lettings?
            lettings_logs_url
          else
            sales_logs_url
          end

    n_logs = pluralize(bulk_upload.logs.count, "log")

    title = "You’ve successfully uploaded #{n_logs}"

    success_description = "The #{bulk_upload.log_type} #{bulk_upload.year_combo} data you uploaded has been checked. The #{n_logs} you uploaded are now complete."

    send_email(
      user.email,
      COMPLETE_TEMPLATE_ID,
      {
        title:,
        filename: bulk_upload.filename,
        upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
        success_description:,
        logs_link: url,
      },
    )
  end

  def send_correct_and_upload_again_mail(bulk_upload:)
    summary_report_link = if BulkUploadErrorSummaryTableComponent.new(bulk_upload:).errors?
                            summary_bulk_upload_lettings_result_url(bulk_upload)
                          else
                            bulk_upload_lettings_result_url(bulk_upload)
                          end

    send_email(
      bulk_upload.user.email,
      FAILED_CSV_ERRORS_TEMPLATE_ID,
      {
        filename: bulk_upload.filename,
        upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
        year_combo: bulk_upload.year_combo,
        lettings_or_sales: bulk_upload.log_type,
        summary_report_link:,
      },
    )
  end

  def send_bulk_upload_failed_file_setup_error_mail(bulk_upload:)
    bulk_upload_link = if bulk_upload.lettings?
                         start_bulk_upload_lettings_logs_url
                       else
                         start_bulk_upload_sales_logs_url
                       end

    row_parser_class = bulk_upload.prefix_namespace::RowParser

    errors = bulk_upload
      .bulk_upload_errors
      .where(category: "setup")
      .group(:col, :field)
      .count
      .keys
      .sort_by { |_col, field| field }
      .map do |col, field|
        "- #{row_parser_class.question_for_field(field.to_sym)} (Column #{col})"
      end

    send_email(
      bulk_upload.user.email,
      FAILED_FILE_SETUP_ERROR_TEMPLATE_ID,
      {
        filename: bulk_upload.filename,
        upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
        lettings_or_sales: bulk_upload.log_type,
        year_combo: bulk_upload.year_combo,
        errors_list: errors.join("\n"),
        bulk_upload_link:,
      },
    )
  end

  def send_bulk_upload_failed_service_error_mail(bulk_upload:, errors: [])
    bulk_upload_link = if bulk_upload.lettings?
                         start_bulk_upload_lettings_logs_url
                       else
                         start_bulk_upload_sales_logs_url
                       end

    send_email(
      bulk_upload.user.email,
      FAILED_SERVICE_ERROR_TEMPLATE_ID,
      {
        filename: bulk_upload.filename,
        upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
        lettings_or_sales: bulk_upload.log_type,
        year_combo: bulk_upload.year_combo,
        errors: errors.map { |e| "- #{e}" }.join("\n"),
        bulk_upload_link:,
      },
    )
  end
end
