class CollectionResourcesService
  def initialize
    @storage_service = if FeatureToggle.local_storage?
                         Storage::LocalDiskService.new
                       else
                         Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["COLLECTION_RESOURCES_BUCKET"])
                       end
  end

  def get_file(file)
    @storage_service.get_file_io(file)
  rescue StandardError
    nil
  end

  def get_file_metadata(file)
    @storage_service.get_file_metadata(file)
  rescue StandardError
    nil
  end

  def file_exists_on_s3?(file)
    url = "https://#{@storage_service.configuration.bucket_name}.s3.amazonaws.com/#{file}"
    uri = URI.parse(url)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request_head(uri)
    end
    response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
  end

  def upload_collection_resource(filename, file)
    @storage_service.write_file(filename, file)
  end
end
