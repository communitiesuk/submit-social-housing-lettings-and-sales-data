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
  absorbing_organisation = Organisation.find_or_create_by!(
    name: "Absorbing organisation",
    address_line1: "Absorbing organisation address line 1",
    address_line2: "Absorbing organisation address line 2",
    postcode: "SW1P 4DF",
    holds_own_stock: false,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  ) do
    info = "Seeded Absorbing organisation Organisation"
    if Rails.env.development?
      pp info
    else
      Rails.logger.info info
    end
  end

  merging_organisation1 = Organisation.find_or_create_by!(
    name: "Merging organisation 1",
    address_line1: "Merging organisation 1 address line 1",
    address_line2: "Merging organisation 1 address line 2",
    postcode: "BA21 4AT",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "PRP",
  )

  merging_organisation2 = Organisation.find_or_create_by!(
    name: "Merging organisation 2",
    address_line1: "Merging organisation 2 address line 1",
    address_line2: "Merging organisation 2 address line 2",
    postcode: "BA21 4AT",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "PRP",
  )

  absorbing_organisation_stock_owner = Organisation.find_or_create_by!(
    name: "Absorbing organisation Stock Owner",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )

  absorbing_organisation_managing_agent = Organisation.find_or_create_by!(
    name: "Absorbing organisation Managing Agent",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )

  merging_organisation1_stock_owner = Organisation.find_or_create_by!(
    name: "Merging organisation 1 Stock Owner",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )

  merging_organisation2_managing_agent = Organisation.find_or_create_by!(
    name: "Merging organisation 2 Managing Agent",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "PRP",
  )

  # organisation relationships
  OrganisationRelationship.find_or_create_by!(
    parent_organisation: absorbing_organisation,
    child_organisation: absorbing_organisation_managing_agent,
  )
  OrganisationRelationship.find_or_create_by!(
    parent_organisation: absorbing_organisation_stock_owner,
    child_organisation: absorbing_organisation,
  )
  OrganisationRelationship.find_or_create_by!(
    parent_organisation: merging_organisation1_stock_owner,
    child_organisation: merging_organisation1,
  )
  OrganisationRelationship.find_or_create_by!(
    parent_organisation: merging_organisation2,
    child_organisation: merging_organisation2_managing_agent,
  )

  # users

  User.find_or_create_by!(
    name: "Absorbing organisation Provider",
    email: "provider@example.com",
    organisation: org,
    role: "data_provider",
  ) do |user|
    user.password = "password"
    user.confirmed_at = Time.zone.now
  end

  User.find_or_create_by!(
    name: "Absorbing organisation Coordinator",
    email: "coordinator@example.com",
    organisation: org,
    role: "data_coordinator",
    is_dpo: true,
  ) do |user|
    user.password = "password"
    user.confirmed_at = Time.zone.now
    user.is_dpo = true
    create_data_protection_confirmation(user)
  end

  User.find_or_create_by!(
    name: "Absorbing organisation Support",
    email: "support@example.com",
    organisation: org,
    role: "support",
    is_dpo: true,
  ) do |user|
    user.password = "password"
    user.confirmed_at = Time.zone.now
    create_data_protection_confirmation(user)
  end

  merging_organisation1_provider = User.find_or_create_by!(
    name: "Merging organisation 1 Provider",
    email: "merging_organisation1_provider@example.com",
    organisation: org,
    role: "data_provider",
  ) do |user|
    user.password = "password"
    user.confirmed_at = Time.zone.now
  end

  User.find_or_create_by!(
    name: "Merging organisation 1 Coordinator",
    email: "merging_organisation1_coordinator@example.com",
    organisation: org,
    role: "data_coordinator",
    is_dpo: true,
  ) do |user|
    user.password = "password"
    user.confirmed_at = Time.zone.now
    user.is_dpo = true
    create_data_protection_confirmation(user)
  end

  User.find_or_create_by!(
    name: "Merging organisation 2 Provider",
    email: "merging_organisation2_provider@example.com",
    organisation: org,
    role: "data_provider",
  ) do |user|
    user.password = "password"
    user.confirmed_at = Time.zone.now
  end

  User.find_or_create_by!(
    name: "Merging organisation 2 Coordinator",
    email: "merging_organisation2_coordinator@example.com",
    organisation: org,
    role: "data_coordinator",
    is_dpo: true,
  ) do |user|
    user.password = "password"
    user.confirmed_at = Time.zone.now
    user.is_dpo = true
    create_data_protection_confirmation(user)
  end

  # sales logs

  SalesLog.find_or_create_by!(
    created_by: merging_organisation1_provider,
    owning_organisation: merging_organisation1,
    managing_organisation: merging_organisation1,
    saledate: Date.new(2023, 4, 1),
    purchid: "Merging organisation 1 sale date before merge",
    ownershipsch: 1,
    type: 2,
    jointpur: 1,
    jointmore: 1,
  )

  SalesLog.find_or_create_by!(
    created_by: merging_organisation1_provider,
    owning_organisation: merging_organisation1,
    managing_organisation: merging_organisation1,
    saledate: Date.new(2023, 12, 1),
    purchid: "Merging organisation 1 sale date after merge",
    ownershipsch: 2,
    type: 9,
    jointpur: 1,
    jointmore: 1,
  )

  # lettings logs

  LettingsLog.find_or_create_by!(
    created_by: merging_organisation1_provider,
    owning_organisation: merging_organisation1,
    managing_organisation: merging_organisation1,
    startdate: Date.new(2023, 4, 1),
    propcode: "Merging organisation 1 start date before merge",
    renewal: 1,
    rent_type: 1,
  )

  LettingsLog.find_or_create_by!(
    created_by: merging_organisation1_provider,
    owning_organisation: merging_organisation1,
    managing_organisation: merging_organisation1,
    startdate: Date.new(2023, 12, 1),
    propcode: "Merging organisation 1 start date after merge",
    renewal: 1,
    rent_type: 1,
  )

  LettingsLog.find_or_create_by!(
    created_by: merging_organisation2_provider,
    owning_organisation: merging_organisation2,
    managing_organisation: merging_organisation2,
    startdate: Date.new(2023, 4, 1),
    propcode: "Merging organisation 2 start date before merge",
    renewal: 1,
    rent_type: 1,
  )

  LettingsLog.find_or_create_by!(
    created_by: merging_organisation2_provider,
    owning_organisation: merging_organisation2,
    managing_organisation: merging_organisation2,
    startdate: Date.new(2023, 12, 1),
    propcode: "Merging organisation 2 start date after merge",
    renewal: 1,
    rent_type: 1,
  )

  # schemes
  scheme1 = Scheme.create!(
    service_name: "Merging organisation 1 scheme",
    sensitive: 0,
    registered_under_care_act: 1,
    support_type: 2,
    scheme_type: 4,
    intended_stay: "M",
    primary_client_group: "O",
    has_other_client_group: 1,
    secondary_client_group: "H",
    owning_organisation: merging_organisation1,
    arrangement_type: "D",
    confirmed: true,
    created_at: Time.zone.now,
  )

  scheme2 = Scheme.create!(
    service_name: "Merging organisation 2 scheme",
    sensitive: 0,
    registered_under_care_act: 1,
    support_type: 2,
    scheme_type: 5,
    intended_stay: "S",
    primary_client_group: "D",
    secondary_client_group: "E",
    has_other_client_group: 1,
    owning_organisation: merging_organisation2,
    arrangement_type: "D",
    confirmed: true,
    created_at: Time.zone.now,
  )

  Scheme.create!(
    service_name: "Absorbing organisation scheme",
    sensitive: 1,
    registered_under_care_act: 1,
    support_type: 4,
    scheme_type: 7,
    intended_stay: "X",
    primary_client_group: "G",
    has_other_client_group: 1,
    secondary_client_group: "R",
    owning_organisation: absorbing_organisation,
    arrangement_type: "D",
    confirmed: true,
    created_at: Time.zone.now,
  )

  Location.create!(
    scheme: scheme1,
    location_code: "E09000033",
    location_admin_district: "Westminster",
    postcode: "CU193AA",
    name: "Rectory Road",
    type_of_unit: 4,
    units: 1,
    mobility_type: "N",
  )

  Location.create!(
    scheme: scheme1,
    location_code: "E09000033",
    location_admin_district: "Westminster",
    postcode: "DM250DC",
    name: "Smithy Lane",
    type_of_unit: 1,
    units: 1,
    mobility_type: "W",
  )

  Location.create!(
    scheme: scheme2,
    location_code: "E09000033",
    location_admin_district: "Westminster",
    postcode: "YX130WP",
    name: "Smithy Lane",
    type_of_unit: 2,
    units: 1,
    mobility_type: "W",
  )

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
