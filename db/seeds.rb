# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# rubocop:disable Rails/Output
unless Rails.env.test?
  housing_provider1 = Organisation.find_or_create_by!(
    name: "Housing Provider 1",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )
  housing_provider2 = Organisation.find_or_create_by!(
    name: "Housing Provider 2",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  )
  managing_agent1 = Organisation.find_or_create_by!(
    name: "Managing Agent 1",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
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
    name: "DLUHC",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: true,
    other_stock_owners: "None",
    managing_agents_label: "None",
    provider_type: "LA",
  ) do
    info = "Seeded DLUHC Organisation"
    if Rails.env.development?
      pp info
    else
      Rails.logger.info info
    end
  end

  OrganisationRelationship.find_or_create_by!(
    child_organisation: org,
    parent_organisation: housing_provider1,
  )
  OrganisationRelationship.find_or_create_by!(
    child_organisation: org,
    parent_organisation: housing_provider2,
  )
  OrganisationRelationship.find_or_create_by!(
    child_organisation: managing_agent1,
    parent_organisation: org,
  )
  OrganisationRelationship.find_or_create_by!(
    child_organisation: managing_agent2,
    parent_organisation: org,
  )

  if (Rails.env.development? || Rails.env.review?) && User.count.zero?
    User.create!(
      name: "Provider",
      email: "provider@example.com",
      password: "password",
      organisation: org,
      role: "data_provider",
      confirmed_at: Time.zone.now,
    )

    User.create!(
      name: "Coordinator",
      email: "coordinator@example.com",
      password: "password",
      organisation: org,
      role: "data_coordinator",
      confirmed_at: Time.zone.now,
    )

    User.create!(
      name: "Support",
      email: "support@example.com",
      password: "password",
      organisation: org,
      role: "support",
      confirmed_at: Time.zone.now,
    )

    pp "Seeded 3 dummy users"
  end

  if Rails.env.development? || Rails.env.review?
    dummy_org = Organisation.find_or_create_by!(
      name: "FooBar LTD",
      address_line1: "Higher Kingston",
      address_line2: "Yeovil",
      postcode: "BA21 4AT",
      holds_own_stock: false,
      other_stock_owners: "None",
      managing_agents_label: "None",
      provider_type: "LA",
    )

    pp "Seeded dummy FooBar LTD organisation"
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
      secondary_client_group: "H",
      owning_organisation: org,
      managing_organisation: org,
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
      owning_organisation: org,
      managing_organisation: org,
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
      secondary_client_group: "R",
      owning_organisation: dummy_org,
      managing_organisation: dummy_org,
      arrangement_type: "D",
      confirmed: true,
      created_at: Time.zone.now,
    )

    Location.create!(
      scheme: scheme1,
      location_code: "S254-CU193AA",
      postcode: "CU193AA",
      name: "Rectory Road",
      type_of_unit: 4,
      units: 1,
      mobility_type: "N",
    )

    Location.create!(
      scheme: scheme1,
      location_code: "S254-DM250DC",
      postcode: "DM250DC",
      name: "Smithy Lane",
      type_of_unit: 1,
      units: 1,
      mobility_type: "W",
    )

    Location.create!(
      scheme: scheme2,
      location_code: "S254-YX130WP",
      postcode: "YX130WP",
      name: "Smithy Lane",
      type_of_unit: 2,
      units: 1,
      mobility_type: "W",
    )
  end

  pp "Seeded 3 dummy schemes"
  if LaRentRange.count.zero?
    Dir.glob("config/rent_range_data/*.csv").each do |path|
      start_year = File.basename(path, ".csv")
      Rake::Task["data_import:rent_ranges"].invoke(start_year, path)
      Rake::Task["data_import:rent_ranges"].reenable
    end
  end
end
# rubocop:enable Rails/Output
