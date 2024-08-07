class DeviseNotifyMailer < Devise::Mailer
  require "notifications/client"

  def notify_client
    @notify_client ||= ::Notifications::Client.new(ENV["GOVUK_NOTIFY_API_KEY"])
  end

  def send_email(email_address, template_id, personalisation)
    return true if intercept_send?(email_address)

    notify_client.send_email(
      email_address:,
      template_id:,
      personalisation:,
    )
  rescue Notifications::Client::BadRequestError => e
    Sentry.capture_exception(e)

    true
  end

  def personalisation(record, token, url, username: false)
    {
      name: record.name || record.email,
      email: username || record.email,
      organisation: record.respond_to?(:organisation) ? record.organisation.name : "",
      link: "#{url}#{token}",
    }
  end

  def reset_password_instructions(record, token, _opts = {})
    base = public_send("edit_#{record.class.name.underscore}_password_url")
    url = "#{base}?reset_password_token="
    send_email(
      record.email,
      record.reset_password_notify_template,
      personalisation(record, token, url),
    )
  end

  def confirmation_instructions(record, token, _opts = {})
    if email_changed?(record)
      send_email_changed_to_old_email(record)
      send_email_changed_to_new_email(record, token)
    elsif !record.confirmed? && record.unconfirmed_email
      send_confirmation_email(record.unconfirmed_email, record, token, record.unconfirmed_email)
      send_email_changed_to_old_email(record)
    else
      send_confirmation_email(record.email, record, token, record.email)
    end
  end

  def intercept_send?(email)
    return false unless email_allowlist

    email_domain = email.split("@").last.downcase
    !(Rails.env.production? || Rails.env.test?) && email_allowlist.exclude?(email_domain)
  end

  def email_allowlist
    Rails.application.credentials[:email_allowlist] || []
  end

  def send_email_changed_to_old_email(record)
    return true if intercept_send?(record.email)

    send_email(
      record.email,
      User::FOR_OLD_EMAIL_CHANGED_BY_OTHER_USER_TEMPLATE_ID,
      {
        new_email: record.unconfirmed_email,
        old_email: record.email,
      },
    )
  end

  def send_email_changed_to_new_email(record, token)
    return true if intercept_send?(record.email)

    link = "#{user_confirmation_url}?confirmation_token=#{token}"

    send_email(
      record.unconfirmed_email,
      User::FOR_NEW_EMAIL_CHANGED_BY_OTHER_USER_TEMPLATE_ID,
      {
        new_email: record.unconfirmed_email,
        old_email: record.email,
        link:,
      },
    )
  end

  def email_changed?(record)
    (
      record.confirmable_template == User::CONFIRMABLE_TEMPLATE_ID && (
        record.unconfirmed_email.present? && record.unconfirmed_email != record.email)
    ) || (
      record.versions.last.changeset.key?("unconfirmed_email") &&
      record.confirmed?
    )
  end

  def send_confirmation_email(email, record, token, username)
    url = "#{user_confirmation_url}?confirmation_token="

    send_email(
      email,
      record.confirmable_template,
      personalisation(record, token, url, username:),
    )
  end

  # def unlock_instructions(record, token, opts = {})
  #   super
  # end
  #
  # def email_changed(record, opts = {})
  #   super
  # end
  #
  # def password_change(record, opts = {})
  #   super
  # end
end
