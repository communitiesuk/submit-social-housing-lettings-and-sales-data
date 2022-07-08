# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# rubocop:disable Rails/Output
unless Rails.env.test?
  org = Organisation.find_or_create_by!(
    name: "DLUHC",
    address_line1: "2 Marsham Street",
    address_line2: "London",
    postcode: "SW1P 4DF",
    holds_own_stock: false,
    other_stock_owners: "None",
    managing_agents: "None",
    provider_type: "LA",
  ) do
    info = "Seeded DLUHC Organisation"
    if Rails.env.development?
      pp info
    else
      Rails.logger.info info
    end
  end

  if Rails.env.development? && User.count.zero?
    User.create!(
      email: "provider@example.com",
      password: "password",
      organisation: org,
      role: "data_provider",
      confirmed_at: Time.zone.now,
    )

    User.create!(
      email: "coordinator@example.com",
      password: "password",
      organisation: org,
      role: "data_coordinator",
      confirmed_at: Time.zone.now,
    )

    User.create!(
      email: "support@example.com",
      password: "password",
      organisation: org,
      role: "support",
      confirmed_at: Time.zone.now,
    )

    pp "Seeded 3 dummy users"
  end

  if Rails.env.development?
    dummy_org = Organisation.find_or_create_by!(
      name: "FooBar LTD",
      address_line1: "Higher Kingston",
      address_line2: "Yeovil",
      postcode: "BA21 4AT",
      holds_own_stock: false,
      other_stock_owners: "None",
      managing_agents: "None",
      provider_type: "LA",
    )

    pp "Seeded dummy FooBar LTD organisation"
  end

  if Rails.env.development? && Scheme.count.zero?
    scheme1 = Scheme.create!(
      service_name: "Beulahside Care",
      sensitive: 0,
      registered_under_care_act: 0,
      support_type: 1,
      scheme_type: 4,
      intended_stay: "M",
      primary_client_group: "O",
      secondary_client_group: "H",
      owning_organisation: org,
      created_at: Time.zone.now,
    )

    scheme2 = Scheme.create!(
      service_name: "Abdullahview Point",
      sensitive: 0,
      registered_under_care_act: 1,
      support_type: 1,
      scheme_type: 5,
      intended_stay: "S",
      primary_client_group: "D",
      secondary_client_group: "E",
      owning_organisation: org,
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
      created_at: Time.zone.now,
    )

    Location.create!(
      scheme: scheme1,
      location_code: "S254-CU193AA",
      postcode: "CU193AA",
      name: "Rectory Road",
      type_of_unit: 4,
      type_of_building: "Purpose-built",
      county: "Mid Sussex",
      wheelchair_adaptation: 0,
    )

    Location.create!(
      scheme: scheme1,
      location_code: "S254-DM250DC",
      postcode: "DM250DC",
      name: "Smithy Lane",
      type_of_unit: 1,
      type_of_building: "Converted from previous residential or non-residential property",
      county: "Fife",
      wheelchair_adaptation: 1,
    )

    Location.create!(
      scheme: scheme2,
      location_code: "S254-YX130WP",
      postcode: "YX130WP",
      name: "Smithy Lane",
      type_of_unit: 2,
      type_of_building: "Converted from previous residential or non-residential property",
      county: "Rochford",
      wheelchair_adaptation: 1,
    )
  end

  pp "Seeded 3 dummy schemes"
  if LaRentRange.count.zero?
    Dir.glob("config/rent_range_data/*.csv").each do |path|
      start_year = File.basename(path, ".csv")
      Rake::Task["data_import:rent_ranges"].invoke(start_year, path)
    end
  end
end
# rubocop:enable Rails/Output
