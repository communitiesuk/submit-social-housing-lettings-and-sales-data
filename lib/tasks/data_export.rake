namespace :core do
  desc "Export data CSVs for import into Central Data System (CDS)"
  task data_export_csv: :environment do |_task, _args|
    DataExportCsvJob.perform_later(format, full_update)
  end

  desc "Export data XMLs for import into Central Data System (CDS)"
  task :data_export_xml, %i[full_update] => :environment do |_task, args|
    full_update = args[:full_update].present? && args[:full_update] == "true"

    DataExportXmlJob.perform_later(full_update:)
  end
end
