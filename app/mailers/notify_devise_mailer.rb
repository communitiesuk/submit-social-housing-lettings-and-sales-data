class NotifyDeviseMailer < Devise::Mailer
  require "notifications/client"

  def notify_client
    @notify_client ||= ::Notifications::Client.new(ENV["GOVUK_NOTIFY_API_KEY"])
  end

  def host
    @host ||= ENV["APP_HOST"]
  end

  def send_email(email, template_id, personalisation)
    notify_client.send_email(
      email_address: email,
      template_id: template_id,
      personalisation: personalisation,
    )
  end

  def reset_password_instructions(record, token, _opts = {})
    template_id = "4593417c-500f-452c-8111-0f9d311aad0e"
    personalisation = {
      name: record.name,
      email: record.email,
      link: "https://#{host}/users/password/edit?reset_password_token=#{token}",
    }
    send_email(record.email, template_id, personalisation)
  end

  def confirmation_instructions(record, token, _opts = {})
    template_id = "00cd7163-4213-4596-b4f9-9e72796e0d76"
    personalisation = {
      name: record.name,
      email: record.email,
      organisation: record.organisation.name,
      link: "https://#{host}/users/confirmation?confirmation_token=#{token}",
    }
    send_email(record.email, template_id, personalisation)
  end

  def unlock_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :unlock_instructions, opts)
  end

  def email_changed(record, opts = {})
    devise_mail(record, :email_changed, opts)
  end

  def password_change(record, opts = {})
    devise_mail(record, :password_change, opts)
  end
end
