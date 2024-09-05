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
  stock_owner1 = Organisation.find_or_create_by!(
    name: "Stock Owner 1",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )
  stock_owner2 = Organisation.find_or_create_by!(
    name: "Stock Owner 2",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )
  managing_agent1 = Organisation.find_or_create_by!(
    name: "Managing Agent 1 (PRP)",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "PRP",
  )
  managing_agent2 = Organisation.find_or_create_by!(
    name: "Managing Agent 2",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )

  org = Organisation.find_or_create_by!(
    name: "MHCLG",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  ) do
    info = "Seeded MHCLG Organisation"
    if Rails.env.development?
      pp info
    else
      Rails.logger.info info
    end
  end

  standalone_owns_stock = Organisation.find_or_create_by!(
    name: "Standalone Owns Stock 1 Ltd",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )

  standalone_no_stock = Organisation.find_or_create_by!(
    name: "Standalone No Stock 1 Ltd",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: false,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )

  User.find_or_create_by!(
    name: "Provider Owns Stock",
    email: "provider.owner1@example.com",
    organisation: standalone_owns_stock,
    role: "data_provider",
    is_dpo: true,
  ) do |user|
    user.password = ENV["REVIEW_APP_USER_PASSWORD"]
    user.confirmed_at = Time.zone.now
    create_data_protection_confirmation(user)
  end

  User.find_or_create_by!(
    name: "Coordinator Owns Stock",
    email: "coordinator.owner1@example.com",
    organisation: standalone_owns_stock,
    role: "data_coordinator",
    is_dpo: true,
  ) do |user|
    user.password = ENV["REVIEW_APP_USER_PASSWORD"]
    user.confirmed_at = Time.zone.now
    create_data_protection_confirmation(user)
  end

  User.find_or_create_by!(
    name: "Provider No Stock",
    email: "provider.nostock@example.com",
    organisation: standalone_no_stock,
    role: "data_provider",
    is_dpo: true,
  ) do |user|
    user.password = ENV["REVIEW_APP_USER_PASSWORD"]
    user.confirmed_at = Time.zone.now
    create_data_protection_confirmation(user)
  end

  User.find_or_create_by!(
    name: "Coordinator No Stock",
    email: "coordinator.nostock@example.com",
    organisation: standalone_no_stock,
    role: "data_coordinator",
  ) do |user|
    user.password = ENV["REVIEW_APP_USER_PASSWORD"]
    user.confirmed_at = Time.zone.now
  end

  User.find_or_create_by!(
    name: "Stock owner 1",
    email: "stock_owner1_dpo@example.com",
    organisation: stock_owner1,
    role: "data_coordinator",
    is_dpo: true,
  ) do |user|
    user.password = ENV["REVIEW_APP_USER_PASSWORD"]
    user.confirmed_at = Time.zone.now
    create_data_protection_confirmation(user)
  end

  User.find_or_create_by!(
    name: "Stock owner 2",
    email: "stock_owner2_dpo@example.com",
    organisation: stock_owner2,
    role: "data_coordinator",
    is_dpo: true,
  ) do |user|
    user.password = ENV["REVIEW_APP_USER_PASSWORD"]
    user.confirmed_at = Time.zone.now
    create_data_protection_confirmation(user)
  end

  User.find_or_create_by!(
    name: "Managing agent 1",
    email: "managing_agent1_dpo@example.com",
    organisation: managing_agent1,
    role: "data_coordinator",
    is_dpo: true,
  ) do |user|
    user.password = ENV["REVIEW_APP_USER_PASSWORD"]
    user.confirmed_at = Time.zone.now
    create_data_protection_confirmation(user)
  end

  User.find_or_create_by!(
    name: "Managing agent 2",
    email: "managing_agent2_dpo@example.com",
    organisation: managing_agent2,
    role: "data_coordinator",
    is_dpo: true,
  ) do |user|
    user.password = ENV["REVIEW_APP_USER_PASSWORD"]
    user.confirmed_at = Time.zone.now
    create_data_protection_confirmation(user)
  end

  OrganisationRelationship.find_or_create_by!(
    parent_organisation: stock_owner1,
    child_organisation: org,
  )
  OrganisationRelationship.find_or_create_by!(
    parent_organisation: stock_owner2,
    child_organisation: org,
  )
  OrganisationRelationship.find_or_create_by!(
    parent_organisation: org,
    child_organisation: managing_agent1,
  )
  OrganisationRelationship.find_or_create_by!(
    parent_organisation: org,
    child_organisation: managing_agent2,
  )

  if Rails.env.development? || Rails.env.review?
    User.find_or_create_by!(
      name: "Provider",
      email: "provider@example.com",
      organisation: org,
      role: "data_provider",
    ) do |user|
      user.password = ENV["REVIEW_APP_USER_PASSWORD"]
      user.confirmed_at = Time.zone.now
    end

    User.find_or_create_by!(
      name: "Coordinator",
      email: "coordinator@example.com",
      organisation: org,
      role: "data_coordinator",
      is_dpo: true,
    ) do |user|
      user.password = ENV["REVIEW_APP_USER_PASSWORD"]
      user.confirmed_at = Time.zone.now
      user.is_dpo = true
      create_data_protection_confirmation(user)
    end

    User.find_or_create_by!(
      name: "Coordinator",
      email: "coordinator1@example.com",
      organisation: org,
      role: "data_coordinator",
      is_dpo: true,
    ) do |user|
      user.password = "password"
      user.confirmed_at = Time.zone.now
      user.is_dpo = true
    end

    support_user = User.find_or_create_by!(
      name: "Support",
      email: "support@example.com",
      organisation: org,
      role: "support",
      is_dpo: true,
    ) do |user|
      user.password = ENV["REVIEW_APP_USER_PASSWORD"]
      user.confirmed_at = Time.zone.now
      create_data_protection_confirmation(user)
    end

    pp "Seeded dummy users"
  end

  if (Rails.env.development? || Rails.env.review?) && SalesLog.count.zero?
    SalesLog.find_or_create_by!(
      assigned_to: support_user,
      owning_organisation: org,
      managing_organisation: org,
      saledate: Time.zone.today,
      purchid: "1",
      ownershipsch: 1,
      type: 2,
      jointpur: 1,
      jointmore: 1,
    )

    SalesLog.find_or_create_by!(
      assigned_to: support_user,
      owning_organisation: org,
      managing_organisation: org,
      saledate: Time.zone.today,
      purchid: "1",
      ownershipsch: 2,
      type: 9,
      jointpur: 1,
      jointmore: 1,
    )

    SalesLog.find_or_create_by!(
      assigned_to: support_user,
      owning_organisation: org,
      managing_organisation: org,
      saledate: Time.zone.today,
      purchid: "1",
      ownershipsch: 3,
      type: 10,
      companybuy: 1,
    )

    pp "Seeded a sales log of each type"
  end

  if Rails.env.development? || Rails.env.review?
    dummy_org = Organisation.find_or_create_by!(
      name: "FooBar LTD",
      address_line1: "Higher Kingston",
      address_line2: "Yeovil",
      postcode: "BA21 4AT",
      holds_own_stock: true,
      other_stock_owners: "None",
      managing_agents_label: "None",
      provider_type: "LA",
    )

    pp "Seeded dummy FooBar LTD organisation"

    User.find_or_create_by!(
      name: "Dummy user",
      email: "dummy_org@example.com",
      organisation: dummy_org,
      role: "data_provider",
      is_dpo: true,
    ) do |user|
      user.password = ENV["REVIEW_APP_USER_PASSWORD"]
      user.confirmed_at = Time.zone.now
      create_data_protection_confirmation(user)
    end
  end

  if (Rails.env.development? || Rails.env.review?) && Scheme.count.zero?
    scheme1 = Scheme.create!(
      service_name: "Beulahside Care",
      sensitive: 0,
      registered_under_care_act: 1,
      support_type: 2,
      scheme_type: 4,
      intended_stay: "M",
      primary_client_group: "O",
      has_other_client_group: 1,
      secondary_client_group: "H",
      owning_organisation: org,
      arrangement_type: "D",
      confirmed: true,
      created_at: Time.zone.now,
    )

    scheme2 = Scheme.create!(
      service_name: "Abdullahview Point",
      sensitive: 0,
      registered_under_care_act: 1,
      support_type: 2,
      scheme_type: 5,
      intended_stay: "S",
      primary_client_group: "D",
      secondary_client_group: "E",
      has_other_client_group: 1,
      owning_organisation: org,
      arrangement_type: "D",
      confirmed: true,
      created_at: Time.zone.now,
    )

    Scheme.create!(
      service_name: "Caspermouth Center",
      sensitive: 1,
      registered_under_care_act: 1,
      support_type: 4,
      scheme_type: 7,
      intended_stay: "X",
      primary_client_group: "G",
      has_other_client_group: 1,
      secondary_client_group: "R",
      owning_organisation: dummy_org,
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
    pp "Seeded dummy schemes"
  end

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
