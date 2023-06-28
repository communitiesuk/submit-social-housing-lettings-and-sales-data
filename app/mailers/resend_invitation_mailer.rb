class ResendInvitationMailer < NotifyMailer
  def resend_invitation_email(user)
    user.send_confirmation_instructions
  end
end
