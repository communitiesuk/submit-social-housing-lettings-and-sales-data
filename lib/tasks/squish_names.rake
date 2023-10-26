desc "Squish names of locations, schemes, users, and organisations"
task squish_names: :environment do
  Location.find_each do |location|
    location.name&.squish!
    location.save!(validate: false)
  end
  Scheme.find_each do |scheme|
    scheme.service_name&.squish!
    scheme.save!(validate: false)
  end
  User.find_each do |user|
    user.name&.squish!
    user.save!(validate: false)
  end
  Organisation.find_each do |organisation|
    organisation.name&.squish!
    organisation.save!(validate: false)
  end
end
