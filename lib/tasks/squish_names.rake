desc "Squish names of locations, schemes, users, and organisations"
task squish_names: :environment do
  Location.find_each do |location|
    location.name&.squish!
    location.save!
  end
  Scheme.find_each do |scheme|
    scheme.service_name&.squish!
    scheme.save!
  end
  User.find_each do |user|
    user.name&.squish!
    user.save!
  end
  Organisation.find_each do |organisation|
    organisation.name&.squish!
    organisation.save!
  end
end
