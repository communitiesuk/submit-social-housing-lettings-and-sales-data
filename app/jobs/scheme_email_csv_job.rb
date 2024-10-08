class SchemeEmailCsvJob < ApplicationJob
  queue_as :default

  BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8

  EXPIRATION_TIME = 24.hours.to_i

  def perform(user, search_term = nil, filters = {}, all_orgs = false, organisation = nil, download_type = "combined") # rubocop:disable Style/OptionalBooleanParameter - sidekiq can't serialise named params
    unfiltered_schemes = if organisation.present? && user.support?
                           Scheme.where(owning_organisation: [organisation] + organisation.parent_organisations)
                         else
                           user.schemes
                         end
    filtered_schemes = FilterManager.filter_schemes(unfiltered_schemes, search_term, filters, all_orgs, user)
    csv_string = Csv::SchemeCsvService.new(download_type:).prepare_csv(filtered_schemes)

    case download_type
    when "schemes"
      filename = "#{['schemes', organisation&.name, Time.zone.now].compact.join('-')}.csv"
    when "locations"
      filename = "#{['locations', organisation&.name, Time.zone.now].compact.join('-')}.csv"
    when "combined"
      filename = "#{['schemes-and-locations', organisation&.name, Time.zone.now].compact.join('-')}.csv"
    end

    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
    storage_service.write_file(filename, BYTE_ORDER_MARK + csv_string)

    url = storage_service.get_presigned_url(filename, EXPIRATION_TIME)

    CsvDownloadMailer.new.send_csv_download_mail(user, url, EXPIRATION_TIME)
  end
end
