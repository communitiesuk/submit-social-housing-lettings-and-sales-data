namespace :core do
  desc "Export data XMLs for import into Central Data System (CDS)"
  task :data_export, %i[format full_update] => :environment do |_task, args|
    format = args[:format]
    full_update = args[:full_update].present? && args[:full_update] == "true"

    DataExportJob.perform_later(format, full_update)
  end
end
