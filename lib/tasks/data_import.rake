namespace :core do
  desc "Import data XMLs from legacy CORE"
  task :data_import, %i[type path] => :environment do |_task, args|
    type = args[:type]
    path = args[:path]
    raise "Usage: rake core:data_import['data_type', 'path/to/xml_files']" if path.blank? || type.blank?

    storage_service = Storage::S3Service.new(Configuration::PaasConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])

    case type
    when "organisation"
      Imports::OrganisationImportService.new(storage_service).create_organisations(path)
    when "scheme"
      Imports::SchemeImportService.new(storage_service).create_schemes(path)
    when "scheme-location"
      Imports::SchemeLocationImportService.new(storage_service).create_scheme_locations(path)
    when "user"
      Imports::UserImportService.new(storage_service).create_users(path)
    when "data-protection-confirmation"
      Imports::DataProtectionConfirmationImportService.new(storage_service).create_data_protection_confirmations(path)
    when "organisation-rent-periods"
      Imports::OrganisationRentPeriodImportService.new(storage_service).create_organisation_rent_periods(path)
    when "lettings-logs"
      Imports::LettingsLogsImportService.new(storage_service).create_logs(path)
    when "sales-logs"
      Imports::SalesLogsImportService.new(storage_service).create_logs(path)
    else
      raise "Type #{type} is not supported by data_import"
    end
  end

  desc "Persist user and org data on data sharing confirmations"
  task persist_user_and_org_data_on_data_sharing_confirmations: :environment do |_task|
    DataProtectionConfirmation.all.includes(:data_protection_officer, :organisation).each do |dpc|
      dpc.update!(
        organisation_name: dpc.organisation.name,
        organisation_address: dpc.organisation.address_row,
        signed_at: dpc.created_at,
        organisation_phone_number: dpc.organisation.phone,
        data_protection_officer_email: dpc.data_protection_officer.email,
        data_protection_officer_name: dpc.data_protection_officer.name,
      )
      print "."
    end

    puts "done"
  end
end
