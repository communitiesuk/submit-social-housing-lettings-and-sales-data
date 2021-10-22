# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?


income_ranges = [
  {economic_status: "full_time",         soft_min: 143, soft_max: 730, hard_min: 90, hard_max: 1230},
  {economic_status: "part_time",         soft_min: 67,  soft_max: 620, hard_min: 50, hard_max: 950},
  {economic_status: "gov_training",      soft_min: 80,  soft_max: 480, hard_min: 40, hard_max: 990},
  {economic_status: "job_seeker",        soft_min: 50,  soft_max: 370, hard_min: 10, hard_max: 450},
  {economic_status: "retired",           soft_min: 50,  soft_max: 380, hard_min: 10, hard_max: 690},
  {economic_status: "not_seeking_work",  soft_min: 53,  soft_max: 540, hard_min: 10, hard_max: 890},
  {economic_status: "full_time_student", soft_min: 47,  soft_max: 460, hard_min: 10, hard_max: 1300},
  {economic_status: "unable_to_work",    soft_min: 54,  soft_max: 460, hard_min: 10, hard_max: 820},
  {economic_status: "child_under_16",    soft_min: 50,  soft_max: 450, hard_min: 10, hard_max: 750},
  {economic_status: "other_adult",       soft_min: 50,  soft_max: 580, hard_min: 10, hard_max: 1040},
  {economic_status: "refused",           soft_min: 47,  soft_max: 730, hard_min: 10, hard_max: 1300}
]

income_ranges.each do |income_range|
  IncomeRange.find_or_create_by(income_range)
end
