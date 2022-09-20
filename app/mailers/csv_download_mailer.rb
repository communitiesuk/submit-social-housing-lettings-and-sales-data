class CsvDownloadMailer < NotifyMailer
  CSV_DOWNLOAD_TEMPLATE_ID = "7890e3b9-8c0d-4d08-bafe-427fd7cd95bf".freeze

  def send_csv_download_mail(user, link, duration)
    send_email(
      user.email,
      CSV_DOWNLOAD_TEMPLATE_ID,
      { name: user.name, link:, duration: ActiveSupport::Duration.build(duration).inspect },
    )
  end
end
