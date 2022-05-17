namespace :onboarding_emails do
  desc "Send onboarding emails to private beta users"
  task :send, %i[organisation_id] => :environment do |_task, args|
    organisation_id = args[:organisation_id]
    host = ENV["APP_HOST"]
    raise "Organisation id must be provided" unless organisation_id
    raise "Host is not set" unless host

    organisation = Organisation.find(organisation_id)
    raise "Organisation #{organisation_id} does not exist" unless organisation

    organisation.users.each do |user|
      next unless URI::MailTo::EMAIL_REGEXP.match?(user.email)

      user.send_confirmation_instructions
    end
  end
end
