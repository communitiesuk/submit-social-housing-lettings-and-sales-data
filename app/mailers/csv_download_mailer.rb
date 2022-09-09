class CsvDownloadMailer
  require "notifications/client"

  CSV_DOWNLOAD_TEMPLATE_ID = "7890e3b9-8c0d-4d08-bafe-427fd7cd95bf".freeze

  def notify_client
    @notify_client ||= ::Notifications::Client.new(ENV["GOVUK_NOTIFY_API_KEY"])
  end

  def send_email(user, link, duration)
    return true if intercept_send?(user.email)

    notify_client.send_email(
      email_address: user.email,
      template_id: CSV_DOWNLOAD_TEMPLATE_ID,
      personalisation: { name: user.name || user.email, link:, duration: ActiveSupport::Duration.build(duration).inspect },
    )
  end

  def intercept_send?(email)
    return false unless email_allowlist

    email_domain = email.split("@").last.downcase
    !(Rails.env.production? || Rails.env.test?) && email_allowlist.exclude?(email_domain)
  end

  def email_allowlist
    Rails.application.credentials[:email_allowlist]
  end
end
