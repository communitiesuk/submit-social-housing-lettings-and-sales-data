class NotifyDeviseMailer < Devise::Mailer
  require 'notifications/client'

  def reset_password_instructions(record, token, opts = {})
    client = ::Notifications::Client.new(ENV["GOVUK_NOTIFY_API_KEY"])
    client.send_email(
      email_address: record.email,
      template_id: "8f1dea41-60e8-4aa2-a23b-f3a751a7438f",
      personalisation: {
        email: record.email,
        link: "#{ENV['host']}/users/password/edit?reset_password_token=#{token}"
      }
    )
  end
end
