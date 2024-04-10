class CreateAddressesCsvJob < ApplicationJob
  queue_as :default

  BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8

  def perform(organisation, log_type)
    csv_service = Csv::MissingAddressesCsvService.new(organisation, [])
    case log_type
    when "lettings"
      csv_string = csv_service.create_lettings_addresses_csv
      filename = "#{['lettings-logs-addresses', organisation.name, Time.zone.now].compact.join('-')}.csv"
    when "sales"
      csv_string = csv_service.create_sales_addresses_csv
      filename = "#{['sales-logs-addresses', organisation.name, Time.zone.now].compact.join('-')}.csv"
    end

    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
    storage_service.write_file(filename, BYTE_ORDER_MARK + csv_string)

    Rails.logger.info("Created addresses file: #{filename}")
  end
end
