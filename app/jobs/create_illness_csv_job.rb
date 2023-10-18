class CreateIllnessCsvJob < ApplicationJob
  queue_as :default

  BYTE_ORDER_MARK = "\uFEFF".freeze # Required to ensure Excel always reads CSV as UTF-8

  def perform(organisation)
    csv_service = Csv::MissingIllnessCsvService.new(organisation)

    csv_string = csv_service.create_illness_csv
    filename = "#{['missing-illness', organisation.name, Time.zone.now].compact.join('-')}.csv"

    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["CSV_DOWNLOAD_PAAS_INSTANCE"])
    storage_service.write_file(filename, BYTE_ORDER_MARK + csv_string)

    Rails.logger.info("Created illness file: #{filename}")
  end
end
