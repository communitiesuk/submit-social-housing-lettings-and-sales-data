namespace :data_import do
  desc "Add CsvVariableDefinition records for each file in the specified directory"
  task :add_variable_definitions, [:path] => :environment do |_task, args|
    path = Rails.root.join(args[:path])
    service = Imports::VariableDefinitionsService.new(path:)
    service.call
    Rails.logger.info "CSV Variable Definitions: #{service.count} total records added"
  end
end
