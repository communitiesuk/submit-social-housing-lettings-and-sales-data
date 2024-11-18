class EmailCsvJob < ApplicationJob
  queue_as :default

  BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8

  EXPIRATION_TIME = 24.hours.to_i

  def perform(user, search_term = nil, filters = {}, all_orgs = false, organisation = nil, codes_only_export = false, log_type = "lettings", year = nil) # rubocop:disable Style/OptionalBooleanParameter - sidekiq can't serialise named params
    export_type = codes_only_export ? "codes" : "labels"
    case log_type
    when "lettings"
      unfiltered_logs = organisation.present? && user.support? ? LettingsLog.visible.where(owning_organisation_id: organisation.id) : user.lettings_logs.visible
      filtered_logs = FilterManager.filter_logs(unfiltered_logs, search_term, filters, all_orgs, user)
      csv_string = Csv::LettingsLogCsvService.new(user:, export_type:, year:).prepare_csv(filtered_logs)
    when "sales"
      unfiltered_logs = organisation.present? && user.support? ? SalesLog.visible.where(owning_organisation_id: organisation.id) : user.sales_logs.visible
      filtered_logs = FilterManager.filter_logs(unfiltered_logs, search_term, filters, all_orgs, user)
      csv_string = Csv::SalesLogCsvService.new(user:, export_type:, year:).prepare_csv(filtered_logs)
    end

    filename = "#{[log_type, 'logs', organisation&.name, Time.zone.now].compact.join('-')}.csv"

    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
    storage_service.write_file(filename, BYTE_ORDER_MARK + csv_string)
    CsvDownload.create!(user:, organisation: user.organisation, filename:, download_type: log_type)

    url = storage_service.get_presigned_url(filename, EXPIRATION_TIME)

    CsvDownloadMailer.new.send_csv_download_mail(user, url, EXPIRATION_TIME)
  end
end
