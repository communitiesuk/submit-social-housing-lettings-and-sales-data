class CollectionResourcesService
  def initialize
    @storage_service = if Rails.env.development?
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
end
