FactoryBot.define do
  factory :csv_variable_definition do
    variable { "variable" }
    definition { "definition" }
    log_type { "log" }
    user_type { "support" }
    year { 2024 }
  end
end
