class EmailMissingAddressesCsvJob < ApplicationJob
  queue_as :default

  BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8
  EXPIRATION_TIME = 1.week.to_i
  MISSING_ADDRESSES_THRESHOLD = 50

  def perform(user_ids, organisation, log_type, skip_uprn_issue_organisations)
    csv_service = Csv::MissingAddressesCsvService.new(organisation, skip_uprn_issue_organisations)
    case log_type
    when "lettings"
      csv_string = csv_service.create_missing_lettings_addresses_csv
      filename = "#{['missing-lettings-logs-addresses', organisation.name, Time.zone.now].compact.join('-')}.csv"
      email_method = :send_missing_lettings_addresses_csv_download_mail
    when "sales"
      csv_string = csv_service.create_missing_sales_addresses_csv
      filename = "#{['missing-sales-logs-addresses', organisation.name, Time.zone.now].compact.join('-')}.csv"
      email_method = :send_missing_sales_addresses_csv_download_mail
    end

    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["CSV_DOWNLOAD_PAAS_INSTANCE"])
    storage_service.write_file(filename, BYTE_ORDER_MARK + csv_string)

    url = storage_service.get_presigned_url(filename, EXPIRATION_TIME)

    user_ids.each do |id|
      user = User.find(id)
      next if user.blank?

      CsvDownloadMailer.new.send(email_method, user, url, EXPIRATION_TIME)
    end
  end
end
