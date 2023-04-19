class EmailCsvJob < ApplicationJob
  queue_as :default

  BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8

  EXPIRATION_TIME = 3.hours.to_i

  def perform(user, search_term = nil, filters = {}, all_orgs = false, organisation = nil, codes_only_export = false, log_type = "lettings") # rubocop:disable Style/OptionalBooleanParameter - sidekiq can't serialise named params
    if log_type == "lettings"
      unfiltered_logs = organisation.present? && user.support? ? LettingsLog.visible.where(owning_organisation_id: organisation.id) : user.lettings_logs.visible
    else
      unfiltered_logs = organisation.present? && user.support? ? SalesLog.visible.where(owning_organisation_id: organisation.id) : user.sales_logs.visible
    end
    filtered_logs = FilterService.filter_logs(unfiltered_logs, search_term, filters, all_orgs, user)

    filename = [log_type, "logs", organisation&.name, Time.zone.now].compact.join("-") + ".csv"

    csv_string = if log_type == "sales"
                   export_type = codes_only_export ? "codes" : "labels"
                   Csv::SalesLogCsvService.new(export_type:).prepare_csv(filtered_logs)
                 else
                   filtered_logs.to_csv(user, codes_only_export:)
                 end

    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["CSV_DOWNLOAD_PAAS_INSTANCE"])
    storage_service.write_file(filename, BYTE_ORDER_MARK + csv_string)

    url = storage_service.get_presigned_url(filename, EXPIRATION_TIME)

    CsvDownloadMailer.new.send_csv_download_mail(user, url, EXPIRATION_TIME)
  end
end
