class EmailCsvJob < ApplicationJob
  queue_as :default

  BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8

  def perform(user, search_term = nil, filters = {}, all_orgs = false, organisation = nil) # rubocop:disable Style/OptionalBooleanParameter
    unfiltered_logs = organisation.present? && user.support? ? LettingsLog.all.where(owning_organisation_id: organisation.id) : user.lettings_logs
    filtered_logs = FilterService.filter_lettings_logs(unfiltered_logs, search_term, filters, all_orgs, user)

    filename = organisation.present? ? "logs-#{organisation.name}-#{Time.zone.now}.csv" : "logs-#{Time.zone.now}.csv"

    storage_service = Storage::S3Service.new(Configuration::PaasConfigurationService.new, ENV["CSV_DOWNLOAD_PAAS_INSTANCE"])
    storage_service.write_file(filename, BYTE_ORDER_MARK + filtered_logs.to_csv(user))

    duration = 3.hours.to_i
    url = storage_service.get_presigned_url(filename, duration)

    CsvDownloadMailer.new.send_email(user, url, duration)
  end
end
