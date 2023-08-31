results = {}
record = LettingsLog.find(566_858)
include Validations::SetupValidations
# include Validations::HouseholdValidations
# include Validations::PropertyValidations
# include Validations::FinancialValidations
# include Validations::TenancyValidations
# include Validations::DateValidations
# include Validations::LocalAuthorityValidations

# methods = %w[recalculate_start_year! reset_scheme_location! process_postcode_changes! process_previous_postcode_changes! reset_invalidated_dependent_fields! reset_location_fields! reset_previous_location_fields! set_derived_fields! process_uprn_change!]

# def validate_startdate_setup_speedy(record)
#   return unless record.startdate && date_valid?("startdate", record)
#
#   first_collection_start_date = if record.startdate_was.present?
#                                   previous_collection_start_date
#                                 else
#                                   previous_collection_start_date
#                                 end
#
#   unless record.startdate.between?(first_collection_start_date, current_collection_end_date)
#     record.errors.add :startdate, startdate_validation_error_message
#   end
#
#   validate_merged_organisations_start_date(record)
# end

# methods = Validations::SetupValidations.public_methods.select{ |method| method.starts_with?("validate_") }.map(&:to_s)
# methods += Validations::HouseholdValidations.public_methods.select{ |method| method.starts_with?("validate_") }.map(&:to_s)
# methods += Validations::PropertyValidations.public_methods.select{ |method| method.starts_with?("validate_") }.map(&:to_s)
# methods += Validations::FinancialValidations.public_methods.select{ |method| method.starts_with?("validate_") }.map(&:to_s)
# methods += Validations::TenancyValidations.public_methods.select{ |method| method.starts_with?("validate_") }.map(&:to_s)
# methods += Validations::DateValidations.public_methods.select{ |method| method.starts_with?("validate_") }.map(&:to_s)
# methods += Validations::LocalAuthorityValidations.public_methods.select{ |method| method.starts_with?("validate_") }.map(&:to_s)
methods = %w[validate_startdate_setup]
benchmark_results = Benchmark.measure do
  record.valid?
end

results[:total] = benchmark_results.real

methods.each do |method|
  validation_time = Benchmark.measure { send(method, record) }.real
  results[method] = validation_time
end

puts "Total time: #{results[:total]}"
puts "Validation times:"
results.each do |method, time|
  next if method == :total

  puts "#{method}: #{time}"
end

# formhandler_result = Benchmark.measure do
#   FormHandler.instance.lettings_in_crossover_period?
# end
# formhandler_result

results = {}
record = LettingsLog.find(566_858)
include Validations::SetupValidations
methods = %w[validate_startdate_setup]
benchmark_results = Benchmark.measure do
  record.valid?
end

results[:total] = benchmark_results.real

methods.each do |method|
  validation_time = Benchmark.measure { send(method, record) }.real
  results[method] = validation_time
end

puts "Total time: #{results[:total]}"
puts "Validation times:"
results.each do |method, time|
  next if method == :total

  puts "#{method}: #{time}"
end

org_names = [
  "Affinity (Reading) Ltd.",
  "APNA GHAR HA LTD",
  "Barnsley Metropolitan Borough Council",
  "Berneslai Homes",
  "Bournemouth, Christchurch and Poole (BCP) Council",
  "Bristol City Council",
  "Broxtowe Borough Council",
  "Derby City Council",
  "Derby Homes Ltd.",
  "Gateshead Housing Company",
  "Gateshead Metropolitan Borough Council",
  "Homes for Haringey",
  "Keswick Community Housing Trust Ltd.",
  "Kingston upon Hull City Council",
  "London Borough of Hammersmith and Fulham",
  "London Borough of Haringey",
  "London Borough of Southwark",
  "North Tyneside Metropolitan Borough Council",
  "Nottingham City Council",
  "Nottingham City Homes",
  "Reading Borough Council",
  "South Kesteven District Council",
  "Stoke-on-Trent City Council",
  "Thirteen Group",
  "York Housing Association Ltd.",
]

def delete_organisations(org_names)
  org_names.each do |org_name|
    org = Organisation.find_by(name: org_name)
    next unless org

    org.parent_organisation_relationships.destroy_all
    org.child_organisation_relationships.destroy_all
    org.users.each { |u| u.legacy_users.destroy_all }
    org.owned_lettings_logs.destroy_all
    org.owned_sales_logs.destroy_all
    org.managed_lettings_logs.destroy_all
    org.owned_schemes.each { |s| s.lettings_logs.destroy_all }
    org.owned_schemes.destroy_all
    org.destroy!
    p "#{org_name} and associated objects deleted"
  end
end

delete_organisations(org_names)
