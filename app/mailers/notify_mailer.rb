class NotifyMailer
  require "notifications/client"

  def notify_client
    @notify_client ||= ::Notifications::Client.new(ENV["GOVUK_NOTIFY_API_KEY"])
  end

  def send_email(email, template_id, personalisation)
    return true if intercept_send?(email)

    notify_client.send_email(
      email_address: email,
      template_id:,
      personalisation:,
    )
  end

  def personalisation(record, token, url, username: false)
    {
      name: record.name || record.email,
      email: username || record.email,
      organisation: record.respond_to?(:organisation) ? record.organisation.name : "",
      link: "#{url}#{token}",
    }
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
