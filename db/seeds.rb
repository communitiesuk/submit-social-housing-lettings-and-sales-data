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
    Scheme.create!(
      code: "S878",
      service_name: "Beulahside Care",
      organisation: org,
      created_at: Time.zone.now,
    )

    Scheme.create!(
      code: "S312",
      service_name: "Abdullahview Point",
      organisation: org,
      created_at: Time.zone.now,
    )

    Scheme.create!(
      code: "7XYZ",
      service_name: "Caspermouth Center",
      organisation: dummy_org,
      created_at: Time.zone.now,
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
