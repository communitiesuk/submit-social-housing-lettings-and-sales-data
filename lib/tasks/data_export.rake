namespace :core do
  desc "Export data CSVs for import into Central Data System (CDS)"
  task data_export_csv: :environment do |_task, _args|
    DataExportCsvJob.perform_later
  end

  desc "Export data XMLs for import into Central Data System (CDS)"
  task :data_export_xml, %i[full_update] => :environment do |_task, args|
    full_update = args[:full_update].present? && args[:full_update] == "true"

    DataExportXmlJob.perform_later(full_update:)
  end
end

namespace :illness_type_0 do
  desc "Export log data where illness_type_0 == 1"
  task export: :environment do |_task|
    logs = LettingsLog.where(illness_type_0: 1, status: "completed").includes(created_by: :organisation)
    puts "log_id,created_by_id,organisation_id,organisation_name,startdate"

    logs.each do |log|
      puts [
        log.id,
        log.created_by_id,
        log.created_by.organisation.id,
        log.created_by.organisation.name,
        log.startdate&.strftime("%d/%m/%Y"),
      ].join(",")
    end
  end
end
