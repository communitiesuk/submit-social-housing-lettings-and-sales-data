namespace :form_definition do
    desc "Validate JSON against Generic Form Schema"
    task :validate do
        ruby "app/helpers/json_schema_validation.rb" 
    end
  end