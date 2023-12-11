class SchemeEmailCsvJob < ApplicationJob
  queue_as :default

  BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8

  EXPIRATION_TIME = 24.hours.to_i

  def perform(user, search_term = nil, filters = {}, all_orgs = false, organisation = nil, download_type = "combined") # rubocop:disable Style/OptionalBooleanParameter - sidekiq can't serialise named params
    unfiltered_schemes = organisation.present? && user.support? ? Scheme.where(owning_organisation_id: organisation.id) : user.schemes
    filtered_schemes = FilterManager.filter_schemes(unfiltered_schemes, search_term, filters, all_orgs, user)

    case download_type
    when "schemes"
      csv_string = Csv::SchemeCsvService.new(user:).prepare_csv(filtered_schemes)
      filename = "#{['schemes', organisation&.name, Time.zone.now].compact.join('-')}.csv"
    when "locations"
      filtered_locations = filtered_schemes.map(&:locations).flatten
      csv_string = Csv::LocationCsvService.new(user:).prepare_csv(filtered_locations)
      filename = "#{['locations', organisation&.name, Time.zone.now].compact.join('-')}.csv"
    when "combined"
      filtered_locations = filtered_schemes.map(&:locations).flatten
      csv_string = Csv::SchemeAndLocationCsvService.new(user:).prepare_csv(filtered_locations)
      filename = "#{['schemes-and-locations', organisation&.name, Time.zone.now].compact.join('-')}.csv"
    end

    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["CSV_DOWNLOAD_PAAS_INSTANCE"])
    storage_service.write_file(filename, BYTE_ORDER_MARK + csv_string)

    url = storage_service.get_presigned_url(filename, EXPIRATION_TIME)

    CsvDownloadMailer.new.send_csv_download_mail(user, url, EXPIRATION_TIME)
  end
end
