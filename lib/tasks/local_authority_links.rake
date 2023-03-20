namespace :data_import do
  desc "Import local authority links data"
  task :local_authority_links, %i[path] => :environment do |_task, args|
    path = args[:path]

    raise "Usage: rake data_import:local_authority_links['path/to/csv_file']" if path.blank?

    service = Imports::LocalAuthorityLinksService.new(path:)
    service.call

    pp "Created/updated #{service.count} local authority link records" unless Rails.env.test?
  end
end
