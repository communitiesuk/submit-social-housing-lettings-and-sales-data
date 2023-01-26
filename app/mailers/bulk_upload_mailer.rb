class BulkUploadMailer < NotifyMailer
  BULK_UPLOAD_FAILED_TEMPLATE_ID = "e27abcd4-5295-48c2-b127-e9ee4b781b75".freeze
  BULK_UPLOAD_WITH_ERRORS_TEMPLATE_ID = "eb539005-6234-404e-812d-167728cf4274".freeze

  def send_bulk_upload_failed_mail(user, bulk_upload)
    send_email(
      user.email,
      BULK_UPLOAD_FAILED_TEMPLATE_ID,
      { filename: "1", upload_timestamp: "2", year_combo: "3", lettings_or_sales: "4", error_description: "5", summary_report_link: "6" },
    )
  end

  def send_bulk_upload_with_errors_mail(user, bulk_upload)
    send_email(
      user.email,
      BULK_UPLOAD_WITH_ERRORS_TEMPLATE_ID,
      { title: "1", filename: "2", upload_timestamp: "3", error_description: "4", summary_report_link: "5" },
    )
  end
end
