class LocationOrSchemeDeactivationMailer < NotifyMailer
  DEACTIVATION_TEMPLATE_ID = "8d07a8c3-a4e3-4102-8be7-4ee79e4183fd".freeze

  def send_deactivation_mail(user, log_count, update_logs_url, scheme_name, postcode = nil)
    send_email(
      user.email,
      DEACTIVATION_TEMPLATE_ID,
      {
        log_count:,
        log_or_logs: log_count == 1 ? "log" : "logs",
        update_logs_url:,
        location_or_scheme_description: description(scheme_name, postcode),
      },
    )
  end

  def send_deactivation_mails(logs, update_logs_url, scheme_name, postcode = nil)
    logs.group_by(&:created_by).transform_values(&:count).compact.each do |user, count|
      send_deactivation_mail(user, count, update_logs_url, scheme_name, postcode)
    end
  end

private

  def description(scheme_name, postcode)
    if postcode
      "the #{postcode} location from the #{scheme_name} scheme"
    else
      "the #{scheme_name} scheme"
    end
  end
end
