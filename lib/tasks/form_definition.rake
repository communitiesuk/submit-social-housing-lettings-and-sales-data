# require "app/helpers/json_schema_validation.rb"

namespace :form_definition do
    desc "Validate JSON against Generic Form Schema"
    task :validate do
        puts "#{Rails.root}"
        ruby "lib/tasks/json_schema_validation.rb" 
    end
  end