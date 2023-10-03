class CsvDownloadMailer < NotifyMailer
  CSV_DOWNLOAD_TEMPLATE_ID = "7890e3b9-8c0d-4d08-bafe-427fd7cd95bf".freeze
  CSV_MISSING_LETTINGS_ADDRESSES_DOWNLOAD_TEMPLATE_ID = "7602b6c2-4f44-4da6-8a68-944e39cd8a05".freeze
  CSV_MISSING_SALES_ADDRESSES_DOWNLOAD_TEMPLATE_ID = "1ee6da00-a65e-4a39-b5e5-1846debcb5f8".freeze

  def send_csv_download_mail(user, link, duration)
    send_email(
      user.email,
      CSV_DOWNLOAD_TEMPLATE_ID,
      { name: user.name, link:, duration: ActiveSupport::Duration.build(duration).inspect },
    )
  end

  def send_missing_lettings_addresses_csv_download_mail(user, link, duration)
    send_email(
      user.email,
      CSV_MISSING_LETTINGS_ADDRESSES_DOWNLOAD_TEMPLATE_ID,
      { name: user.name, link:, duration: ActiveSupport::Duration.build(duration).inspect },
    )
  end

  def send_missing_sales_addresses_csv_download_mail(user, link, duration)
    send_email(
      user.email,
      CSV_MISSING_SALES_ADDRESSES_DOWNLOAD_TEMPLATE_ID,
      { name: user.name, link:, duration: ActiveSupport::Duration.build(duration).inspect },
    )
  end
end
