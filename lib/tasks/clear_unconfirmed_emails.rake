desc "Clear unconfimed emails for deactivated users"
task clear_unconfirmed_emails: :environment do
  User.deactivated.where.not(unconfirmed_email: nil).update(unconfirmed_email: nil)
end
