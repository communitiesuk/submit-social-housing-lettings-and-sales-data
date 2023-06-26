class ResendInvitationMailer < NotifyMailer
  include Rails.application.routes.url_helpers

  def resend_invitation_email(user)
    user.send_confirmation_instructions
  end
end
