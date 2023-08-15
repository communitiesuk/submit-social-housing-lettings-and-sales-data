Import = Struct.new("Import", :import_class, :import_method, :folder)

namespace :import do
  desc "Run initial import steps - orgs, schemes, users etc (without triggering user invite emails)"
  task :initial, %i[institutions_csv_name] => :environment do |_task, args|
    institutions_csv_name = args[:institutions_csv_name]
    raise "Usage: rake import:initial['institutions_csv_name']" if institutions_csv_name.blank?

    s3_service = Storage::S3Service.new(PlatformHelper.is_paas? ? Configuration::PaasConfigurationService.new : Configuration::EnvConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    csv = CSV.parse(s3_service.get_file_io(institutions_csv_name), headers: true)
    org_count = csv.length

    initial_import_list = [
      Import.new(Imports::OrganisationImportService, :create_organisations, "institution"),
      Import.new(Imports::SchemeImportService, :create_schemes, "mgmtgroups"),
      Import.new(Imports::SchemeLocationImportService, :create_scheme_locations, "schemes"),
      Import.new(Imports::UserImportService, :create_users, "user"),
      Import.new(Imports::DataProtectionConfirmationImportService, :create_data_protection_confirmations, "dataprotect"),
      Import.new(Imports::OrganisationRentPeriodImportService, :create_organisation_rent_periods, "rent-period"),
    ]

    Rails.logger.info("Beginning initial imports for #{org_count} organisations")

    csv.each do |row|
      archive_path = row[1]
      archive_io = s3_service.get_file_io(archive_path)
      archive_service = Storage::ArchiveService.new(archive_io)

      Rails.logger.info("Performing initial imports for organisation #{row[0]}")

      initial_import_list.each do |step|
        if archive_service.folder_present?(step.folder)
          step.import_class.new(archive_service).send(step.import_method, step.folder)
        end
      end
    end

    Rails.logger.info("Finished initial imports")
  end

  desc "Run logs import steps"
  task :logs, %i[institutions_csv_name] => :environment do |_task, args|
    institutions_csv_name = args[:institutions_csv_name]
    raise "Usage: rake import:logs['institutions_csv_name']" if institutions_csv_name.blank?

    s3_service = Storage::S3Service.new(PlatformHelper.is_paas? ? Configuration::PaasConfigurationService.new : Configuration::EnvConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    csv = CSV.parse(s3_service.get_file_io(institutions_csv_name), headers: true)
    org_count = csv.length

    logs_import_list = [
      Import.new(Imports::LettingsLogsImportService, :create_logs, "logs"),
      Import.new(Imports::SalesLogsImportService, :create_logs, "logs"),
    ]

    Rails.logger.info("Beginning log imports for #{org_count} organisations")

    csv.each do |row|
      archive_path = row[1]
      archive_io = s3_service.get_file_io(archive_path)
      archive_service = Storage::ArchiveService.new(archive_io)

      log_count = row[2].to_i + row[3].to_i + row[4].to_i + row[5].to_i
      Rails.logger.info("Importing logs for organisation #{row[0]}, expecting #{log_count} logs")

      logs_import_list.each do |step|
        if archive_service.folder_present?(step.folder)
          step.import_class.new(archive_service).send(step.import_method, step.folder)
        end
      end
    end

    Rails.logger.info("Log import complete")
  end

  desc "Trigger invite emails for imported users"
  task :trigger_invites, %i[institutions_csv_name] => :environment do |_task, args|
    institutions_csv_name = args[:institutions_csv_name]
    raise "Usage: rake import:trigger_invites['institutions_csv_name']" if institutions_csv_name.blank?

    s3_service = Storage::S3Service.new(PlatformHelper.is_paas? ? Configuration::PaasConfigurationService.new : Configuration::EnvConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    csv = CSV.parse(s3_service.get_file_io(institutions_csv_name), headers: true)

    Rails.logger.info("Triggering user invite emails")

    csv.each do |row|
      organisation = Organisation.find_by(name: row[0])
      next unless organisation

      users = User.where(organisation:, active: true, initial_confirmation_sent: nil)
      users.each { |user| ResendInvitationMailer.resend_invitation_email(user).deliver_later }
    end

    Rails.logger.info("Invite emails triggered")
  end

  desc "Generate migrated logs report"
  task :generate_reports, %i[institutions_csv_name] => :environment do |_task, args|
    institutions_csv_name = args[:institutions_csv_name]
    raise "Usage: rake import:generate_reports['institutions_csv_name']" if institutions_csv_name.blank?

    s3_service = Storage::S3Service.new(PlatformHelper.is_paas? ? Configuration::PaasConfigurationService.new : Configuration::EnvConfigurationService.new, ENV["IMPORT_PAAS_INSTANCE"])
    institutions_csv = CSV.parse(s3_service.get_file_io(institutions_csv_name), headers: true)

    Imports::ImportReportService.new(s3_service, institutions_csv).create_reports(institutions_csv_name)
  end

  desc "Run import from logs step to end"
  task :logs_onwards, %i[institutions_csv_name] => %i[environment logs trigger_invites generate_reports]

  desc "Run a full import for the institutions listed in the named file on s3"
  task :full, %i[institutions_csv_name] => %i[environment initial logs trigger_invites generate_reports]
end
