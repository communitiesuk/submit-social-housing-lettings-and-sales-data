FactoryBot.define do
  factory :csv_variable_definition do
    variable { "variable" }
    definition { "definition" }
    log_type { "lettings" }
    user_type { "support" }
    year { 2024 }
  end
end
