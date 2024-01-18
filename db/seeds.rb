# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# rubocop:disable Rails/Output
def create_data_protection_confirmation(user)
  DataProtectionConfirmation.find_or_create_by!(
    organisation: user.organisation,
    confirmed: true,
    data_protection_officer: user,
    signed_at: Time.zone.local(2019, 1, 1),
    data_protection_officer_email: user.email,
    data_protection_officer_name: user.name,
  )
end

unless Rails.env.test?
  if LocalAuthority.count.zero?
    la_path = "config/local_authorities_data/initial_local_authorities.csv"
    service = Imports::LocalAuthoritiesService.new(path: la_path)
    service.call
  end

  if (Rails.env.development? || Rails.env.review?) && LocalAuthorityLink.count.zero?
    links_data_paths = ["config/local_authorities_data/local_authority_links_2023.csv", "config/local_authorities_data/local_authority_links_2022.csv"]
    links_data_paths.each do |path|
      service = Imports::LocalAuthorityLinksService.new(path:)
      service.call
    end

    pp "Seeded local authority links"
  end

  if LaRentRange.count.zero?
    Dir.glob("config/rent_range_data/*.csv").each do |path|
      start_year = File.basename(path, ".csv")
      service = Imports::RentRangesService.new(start_year:, path:)
      service.call
    end
  end

  if LaSaleRange.count.zero?
    Dir.glob("config/sale_range_data/*.csv").each do |path|
      start_year = File.basename(path, ".csv")
      service = Imports::SaleRangesService.new(start_year:, path:)
      service.call
    end
  end
end

if LocalAuthority.count.zero?
  path = "config/local_authorities_data/initial_local_authorities.csv"
  service = Imports::LocalAuthoritiesService.new(path:)
  service.call
end
# rubocop:enable Rails/Output
