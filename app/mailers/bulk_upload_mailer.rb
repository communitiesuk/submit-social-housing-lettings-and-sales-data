class BulkUploadMailer < NotifyMailer
  BULK_UPLOAD_COMPLETE_TEMPLATE_ID = "83279578-c890-4168-838b-33c9cf0dc9f0".freeze
  BULK_UPLOAD_FAILED_CSV_ERRORS_TEMPLATE_ID = "e27abcd4-5295-48c2-b127-e9ee4b781b75".freeze
  BULK_UPLOAD_FAILED_FILE_SETUP_ERROR_TEMPLATE_ID = "24c9f4c7-96ad-470a-ba31-eb51b7cbafd9".freeze
  BULK_UPLOAD_FAILED_SERVICE_ERROR_TEMPLATE_ID = "c3f6288c-7a74-4e77-99ee-6c4a0f6e125a".freeze
  BULK_UPLOAD_WITH_ERRORS_TEMPLATE_ID = "eb539005-6234-404e-812d-167728cf4274".freeze

  def send_bulk_upload_complete_mail(user, bulk_upload)
    send_email(
      user.email,
      BULK_UPLOAD_COMPLETE_TEMPLATE_ID,
      {
        title: "[#{bulk_upload} title]",
        filename: "[#{bulk_upload} filename]",
        upload_timestamp: "[#{bulk_upload} upload_timestamp]",
        success_description: "[#{bulk_upload} success_description]",
        logs_link: "[#{bulk_upload} logs_link]",
      },
    )
  end

  def send_bulk_upload_failed_csv_errors_mail(user, bulk_upload)
    send_email(
      user.email,
      BULK_UPLOAD_FAILED_CSV_ERRORS_TEMPLATE_ID,
      {
        filename: "[#{bulk_upload} filename]",
        upload_timestamp: "[#{bulk_upload} upload_timestamp]",
        year_combo: "[#{bulk_upload} year_combo]",
        lettings_or_sales: "[#{bulk_upload} lettings_or_sales]",
        error_description: "[#{bulk_upload} error_description]",
        summary_report_link: "[#{bulk_upload} summary_report_link]",
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

  def send_bulk_upload_failed_service_error_mail(user, bulk_upload)
    send_email(
      user.email,
      BULK_UPLOAD_FAILED_SERVICE_ERROR_TEMPLATE_ID,
      {
        filename: "[#{bulk_upload} filename]",
        upload_timestamp: "[#{bulk_upload} upload_timestamp]",
        lettings_or_sales: "[#{bulk_upload} lettings_or_sales]",
        year_combo: "[#{bulk_upload} year_combo]",
        bulk_upload_link: "[#{bulk_upload} bulk_upload_link]",
      },
    )
  end

  def send_bulk_upload_with_errors_mail(user, bulk_upload)
    send_email(
      user.email,
      BULK_UPLOAD_WITH_ERRORS_TEMPLATE_ID,
      {
        title: "[#{bulk_upload} title]",
        filename: "[#{bulk_upload} filename]",
        upload_timestamp: "[#{bulk_upload} upload_timestamp]",
        error_description: "[#{bulk_upload} error_description]",
        summary_report_link: "[#{bulk_upload} summary_report_link]",
      },
    )
  end
end
