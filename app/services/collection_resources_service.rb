class CollectionResourcesService
  def initialize
    @storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["COLLECTION_RESOURCES_BUCKET"])
  end

  def get_file(file)
    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["COLLECTION_RESOURCES_BUCKET"])
    url = "https://#{storage_service.configuration.bucket_name}.s3.amazonaws.com/#{file}"
    uri = URI.parse(url)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request)
    end

    return unless response.is_a?(Net::HTTPSuccess)

    response.body
  end

  def get_file_metadata(file)
    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["COLLECTION_RESOURCES_BUCKET"])
    url = "https://#{storage_service.configuration.bucket_name}.s3.amazonaws.com/#{file}"
    uri = URI.parse(url)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request_head(uri)
    end
    return unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)

    response
  end
end
