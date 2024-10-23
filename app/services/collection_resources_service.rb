class CollectionResourcesService
  def initialize
    @storage_service = if FeatureToggle.local_storage?
                         Storage::LocalDiskService.new
                       else
                         Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["COLLECTION_RESOURCES_BUCKET"])
                       end
  end

  def get_file(file)
    @storage_service.get_file(file)
  rescue StandardError
    nil
  end

  def get_file_metadata(file)
    @storage_service.get_file_metadata(file)
  rescue StandardError
    nil
  end

  def file_exists_on_s3?(file)
    @storage_service.file_exists?(file)
  end

  def upload_collection_resource(filename, file)
    content_type = MiniMime.lookup_by_filename(filename)&.content_type
    @storage_service.write_file(filename, file, content_type:)
  end

  def delete_collection_resource(filename)
    @storage_service.delete_file(filename)
  end
end
