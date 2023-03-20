namespace :data_import do
  desc "Import local authorities data"
  task :local_authorities, %i[path] => :environment do |_task, args|
    path = args[:path]

    raise "Usage: rake data_import:local_authorities['path/to/csv_file']" if path.blank?

    service = Imports::LocalAuthoritiesService.new(path:)
    service.call

    pp "Created/updated #{service.count} local authority records" unless Rails.env.test?
  end
end
