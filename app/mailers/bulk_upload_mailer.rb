class BulkUploadMailer < NotifyMailer
  BULK_UPLOAD_FAILED_CSV_ERRORS_TEMPLATE_ID = "e27abcd4-5295-48c2-b127-e9ee4b781b75".freeze
  BULK_UPLOAD_WITH_ERRORS_TEMPLATE_ID = "eb539005-6234-404e-812d-167728cf4274".freeze

  def send_bulk_upload_failed_csv_errors_mail(user, bulk_upload)
    send_email(
      user.email,
      BULK_UPLOAD_FAILED_CSV_ERRORS_TEMPLATE_ID,
      {
        filename: "[dummy filename]",
        upload_timestamp: "[dummy upload_timestamp]",
        year_combo: "[dummy year_combo]",
        lettings_or_sales: "[dummy lettings_or_sales]",
        error_description: "[dummy error_description]",
        summary_report_link: "[dummy summary_report_link]"
      },
    )
  end

  def send_bulk_upload_with_errors_mail(user, bulk_upload)
    send_email(
      user.email,
      BULK_UPLOAD_WITH_ERRORS_TEMPLATE_ID,
      {
        title: "[dummy title]",
        filename: "[dummy filename]",
        upload_timestamp: "[dummy upload_timestamp]",
        error_description: "[dummy error_description]",
        summary_report_link: "[dummy summary_report_link]"
      },
    )
  end
end
