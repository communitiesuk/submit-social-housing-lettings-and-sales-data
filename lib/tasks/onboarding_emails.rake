namespace :onboarding_emails do
  desc "Send onboarding emails to private beta users"
  task :send, %i[organisation_id host] => :environment do |_task, args|
    organisation_id = args[:organisation_id]
    host = args[:host]
    raise "Organisation id must be provided" unless organisation_id
    raise "host must be provided" unless host

    organisation = Organisation.find(organisation_id)
    raise "Organisation #{organisation_id} does not exist" unless organisation

    organisation.users.each do |user|
      next unless URI::MailTo::EMAIL_REGEXP.match?(user.email)

      onboarding_template_id = "b48bc2cd-5887-4611-8296-d0ab3ed0e7fd".freeze
      token = user.send(:set_reset_password_token)
      url = "#{host}/account/password/edit?reset_password_token=#{token}"
      personalisation = { name: user.name || user.email, link: url }
      DeviseNotifyMailer.new.send_email(user.email, onboarding_template_id, personalisation)
    end
  end
end
