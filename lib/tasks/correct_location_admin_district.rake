desc "Infers location admin district for locations from location code where it's missing"
task correct_location_admin_district: :environment do
  Location.where.not(location_code: nil).where(location_admin_district: nil).each do |location|
    location.update(location_admin_district: LocalAuthority.all.active(Time.zone.today).england.find_by(code: location.location_code)&.name)
  end
end
