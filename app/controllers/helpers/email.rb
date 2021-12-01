module Helpers::Email
  def email_valid?(email)
    email =~ URI::MailTo::EMAIL_REGEXP
  end
end
