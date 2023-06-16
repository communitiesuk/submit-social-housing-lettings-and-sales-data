class DataProtectionConfirmationMailer < NotifyMailer
  include Rails.application.routes.url_helpers
  EMAIL_TEMPLATE_ID = "3dbf78fe-a2c8-4d65-aa19-e4d62695d4a9".freeze

  def send_confirmation_email(user)
    send_email(
      user.email,
      EMAIL_TEMPLATE_ID,
      {
        organisation_name: user.organisation.name,
        link: data_sharing_agreement_organisation_url(user.organisation),
      },
    )
  end
end
