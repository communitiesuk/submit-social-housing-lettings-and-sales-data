namespace :emails do
  desc "Resend invitation emails"
  task :resend_invitation_emails, %i[] => :environment do |_task, _args|
    users = User.where(sign_in_count: 0, active: true)
    users.each(&:send_confirmation_instructions)

    Rails.logger.info("Sent invitation emails to #{users.count} users.")
  end
end
