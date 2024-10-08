class UploadCollectionResourcesService
  def self.upload_collection_resource(filename, file)
    storage_service = Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["COLLECTION_RESOURCES_BUCKET"])
    storage_service.write_file(filename, file)
  end
end
