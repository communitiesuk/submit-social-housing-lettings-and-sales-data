desc "Squish names of locations, schemes, users, and organisations"
task squish_names: :environment do
  Location.where("name LIKE ?", "%  %").each do |location|
    location.name&.squish!
    begin
      location.save!
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end
  Scheme.where("service_name LIKE ?", "%  %").each do |scheme|
    scheme.service_name&.squish!
    begin
      scheme.save!
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end
  User.where("name LIKE ?", "%  %").each do |user|
    user.name&.squish!
    begin
      user.save!
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end
  Organisation.where("name LIKE ?", "%  %").each do |organisation|
    organisation.name&.squish!
    begin
      organisation.save!
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end
end
