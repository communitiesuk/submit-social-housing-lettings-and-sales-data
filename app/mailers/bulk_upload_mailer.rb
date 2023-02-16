class BulkUploadMailer < NotifyMailer
  include ActionView::Helpers::TextHelper

  BULK_UPLOAD_COMPLETE_TEMPLATE_ID = "83279578-c890-4168-838b-33c9cf0dc9f0".freeze
  BULK_UPLOAD_FAILED_CSV_ERRORS_TEMPLATE_ID = "e27abcd4-5295-48c2-b127-e9ee4b781b75".freeze
  BULK_UPLOAD_FAILED_FILE_SETUP_ERROR_TEMPLATE_ID = "24c9f4c7-96ad-470a-ba31-eb51b7cbafd9".freeze
  BULK_UPLOAD_FAILED_SERVICE_ERROR_TEMPLATE_ID = "c3f6288c-7a74-4e77-99ee-6c4a0f6e125a".freeze
  BULK_UPLOAD_WITH_ERRORS_TEMPLATE_ID = "eb539005-6234-404e-812d-167728cf4274".freeze

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
      BULK_UPLOAD_COMPLETE_TEMPLATE_ID,
      {
        title:,
        filename: bulk_upload.filename,
        upload_timestamp: bulk_upload.created_at,
        success_description:,
        logs_link: url,
      },
    )
  end

  def columns_with_errors(bulk_upload:)
    array = bulk_upload.columns_with_errors

    if array.size > 3
      "#{array.take(3).join(', ')} and more"
    else
      array.join(", ")
    end
  end

  def send_correct_and_upload_again_mail(
    any_setup_sections_incomplete,
    over_column_error_threshold,
    any_logs_already_exist,
    any_logs_invalid,
    bulk_upload:
  )

    any_setup_sections_incomplete_error_description = "Placeholder text for setup sections incomplete case."
    over_column_error_threshold_error_description = "You have a lot of similar errors in column #{columns_with_errors(bulk_upload:)}."
    any_logs_already_exist_error_description = "One of the logs you are trying to upload has been created previously."
    any_logs_invalid_error_description = "Placeholder text for invalid logs case."

    errors = []
    errors << any_setup_sections_incomplete_error_description if any_setup_sections_incomplete
    errors << over_column_error_threshold_error_description if over_column_error_threshold
    errors << any_logs_already_exist_error_description if any_logs_already_exist
    errors << any_logs_invalid_error_description if any_logs_invalid

    correct_and_reupload_description = "Please correct your data export and upload again."

    if errors.size == 0
      error_description = correct_and_reupload_description
    else
      error_description = "We noticed the following issues with your upload:\n\n" #{"s" if errors.size > 1}
      errors.each { |error| error_description << "- #{error}\n" }
      error_description << "\n"
    end

    send_email(
      bulk_upload.user.email,
      BULK_UPLOAD_FAILED_CSV_ERRORS_TEMPLATE_ID,
      {
        filename: bulk_upload.filename,
        upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
        year_combo: bulk_upload.year_combo,
        lettings_or_sales: bulk_upload.log_type,
        error_description:,
        summary_report_link: summary_bulk_upload_lettings_result_url(bulk_upload),
      },
    )
  end

  def send_bulk_upload_failed_file_setup_error_mail(user, bulk_upload)
    send_email(
      user.email,
      BULK_UPLOAD_FAILED_FILE_SETUP_ERROR_TEMPLATE_ID,
      {
        filename: "[#{bulk_upload} filename]",
        upload_timestamp: "[#{bulk_upload} upload_timestamp]",
        lettings_or_sales: "[#{bulk_upload} lettings_or_sales]",
        year_combo: "[#{bulk_upload} year_combo]",
        errors_list: "[#{bulk_upload} errors_list]",
        bulk_upload_link: "[#{bulk_upload} bulk_upload_link]",
      },
    )
  end

  def send_bulk_upload_failed_service_error_mail(bulk_upload:)
    bulk_upload_link = if bulk_upload.lettings?
                         start_bulk_upload_lettings_logs_url
                       else
                         start_bulk_upload_sales_logs_url
                       end

    send_email(
      bulk_upload.user.email,
      BULK_UPLOAD_FAILED_SERVICE_ERROR_TEMPLATE_ID,
      {
        filename: bulk_upload.filename,
        upload_timestamp: bulk_upload.created_at,
        lettings_or_sales: bulk_upload.log_type,
        year_combo: bulk_upload.year_combo,
        bulk_upload_link:,
      },
    )
  end

  def send_bulk_upload_with_errors_mail(bulk_upload:)
    count = bulk_upload.logs.where.not(status: %w[completed]).count

    n_logs = pluralize(count, "log")

    title = "We found #{n_logs} with errors"

    error_description = "We created logs from your #{bulk_upload.year_combo} #{bulk_upload.log_type} data. There was a problem with #{count} of the logs. Click the below link to fix these logs."

    send_email(
      bulk_upload.user.email,
      BULK_UPLOAD_WITH_ERRORS_TEMPLATE_ID,
      {
        title:,
        filename: bulk_upload.filename,
        upload_timestamp: bulk_upload.created_at.to_fs(:govuk_date_and_time),
        error_description:,
        summary_report_link: resume_bulk_upload_lettings_result_url(bulk_upload),
      },
    )
  end
end
