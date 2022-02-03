require "notifications/client"

class Sms
  def self.notify_client
    Notifications::Client.new(ENV["GOVUK_NOTIFY_API_KEY"])
  end

  def self.send(phone_number, template_id, args)
    notify_client.send_sms(
      phone_number: phone_number,
      template_id: template_id,
      personalisation: args,
    )
  end
end
