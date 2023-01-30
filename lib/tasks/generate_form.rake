namespace :form do
  desc "Generate form files from JSON"
  task generate_form: :environment do |_task, _args|
    service = Spike::FormGeneratorService.new
    service.call

    pp "Ran"
  end
end
