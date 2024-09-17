namespace :count_duplicates do
  desc "Count the number of duplicate schemes per organisation"
  task scheme_duplicates_per_org: :environment do
    duplicates_csv = CSV.generate(headers: true) do |csv|
      csv << ["Organisation id", "Number of duplicate sets", "Total duplicate schemes"]

      Organisation.visible.each do |organisation|
        if organisation.owned_schemes.duplicate_sets.count.positive?
          csv << [organisation.id, organisation.owned_schemes.duplicate_sets.count, organisation.owned_schemes.duplicate_sets.sum(&:size)]
        end
      end
    end

    BYTE_ORDER_MARK = "\uFEFF".freeze
    EXPIRATION_TIME = 72.hours.to_i
    filename = "scheme-duplicates-#{Time.zone.now}.csv"
    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["BULK_UPLOAD_BUCKET"])
    storage_service.write_file(filename, BYTE_ORDER_MARK + duplicates_csv)

    url = storage_service.get_presigned_url(filename, EXPIRATION_TIME)
    Rails.logger.info("Download URL: #{url}")
  end
end
