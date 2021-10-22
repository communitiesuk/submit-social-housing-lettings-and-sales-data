# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# AdminUser.create!(email: "admin@example.com", password: "password", password_confirmation: "password") if Rails.env.development?

income_ranges = [
  { economic_status: "Full-time - 30 hours or more", soft_min: 143, soft_max: 730, hard_min: 90, hard_max: 1230 },
  { economic_status: "Part-time - Less than 30 hours", soft_min: 67, soft_max: 620, hard_min: 50, hard_max: 950 },
  { economic_status: "In government training into work, such as New Deal", soft_min: 80, soft_max: 480, hard_min: 40, hard_max: 990 },
  { economic_status: "Jobseeker", soft_min: 50, soft_max: 370, hard_min: 10, hard_max: 450 },
  { economic_status: "Retired", soft_min: 50, soft_max: 380, hard_min: 10, hard_max: 690 },
  { economic_status: "Not seeking work", soft_min: 53, soft_max: 540, hard_min: 10, hard_max: 890 },
  { economic_status: "Full-time student", soft_min: 47, soft_max: 460, hard_min: 10, hard_max: 1300 },
  { economic_status: "Unable to work because of long term sick or disability", soft_min: 54, soft_max: 460, hard_min: 10, hard_max: 820 },
  { economic_status: "Child under 16", soft_min: 50, soft_max: 450, hard_min: 10, hard_max: 750 },
  { economic_status: "Other", soft_min: 50, soft_max: 580, hard_min: 10, hard_max: 1040 },
  { economic_status: "Prefer not to say", soft_min: 47, soft_max: 730, hard_min: 10, hard_max: 1300 },
]

income_ranges.each do |income_range|
  IncomeRange.find_or_create_by(income_range)
end
