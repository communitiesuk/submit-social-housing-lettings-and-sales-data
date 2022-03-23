# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

org = Organisation.create!(
  name: "DLUHC",
  address_line1: "2 Marsham Street",
  address_line2: "London",
  postcode: "SW1P 4DF",
  local_authorities: "None",
  holds_own_stock: false,
  other_stock_owners: "None",
  managing_agents: "None",
  provider_type: "LA",
)
User.create!(
  email: "test@example.com",
  password: "password",
  organisation: org,
  role: "data_provider",
)

User.create!(
  email: "coordinator@example.com",
  password: "password",
  organisation: org,
  role: "data_coordinator",
)

AdminUser.create!(email: "admin@example.com", password: "password", phone: "000000000")
