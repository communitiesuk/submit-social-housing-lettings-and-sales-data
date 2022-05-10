include Rails.application.routes.url_helpers

namespace :onboarding_emails do
  desc "Send onboarding emails to private beta users"
  task :send, %i[organisation_id host] => :environment do |_task, args|
    organisation_id = args[:organisation_id]
    host = args[:host]
    raise "Organisation id must be provided" unless organisation_id
    raise "host must be provided" unless host

    organisation = Organisation.find(organisation_id)
    raise "Organisation #{organisation_id} does not exist" unless organisation

    organisation.users.each { |user| user.send_beta_onboarding_email(host) }
  end
end
