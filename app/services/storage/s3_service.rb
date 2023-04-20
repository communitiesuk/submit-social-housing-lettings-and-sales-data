module Storage
  class S3Service < StorageService
    attr_reader :configuration

    def initialize(config_service)
      super()
      @config_service = config_service
      @configuration = create_configuration
      @client = create_client
    end

    def list_files(folder)
      @client.list_objects_v2(bucket: @configuration.bucket_name, prefix: folder)
             .flat_map { |response| response.contents.map(&:key) }
    end

    def folder_present?(folder)
      response = @client.list_objects_v2(bucket: @configuration.bucket_name, prefix: folder, max_keys: 1)
      response.key_count == 1
    end

    def get_presigned_url(file_name, duration)
      Aws::S3::Presigner
        .new({ client: @client })
        .presigned_url(:get_object, bucket: @configuration.bucket_name, key: file_name, expires_in: duration)
    end

    def get_file_io(file_name)
      @client.get_object(bucket: @configuration.bucket_name, key: file_name)
             .body
    end

    def write_file(file_name, data)
      @client.put_object(
        body: data,
        bucket: @configuration.bucket_name,
        key: file_name,
      )
    end

  private

    attr_reader :config_service

    def create_configuration
      StorageConfiguration.new(config_service.credentials)
    end

    def create_client
      credentials =
        Aws::Credentials.new(
          @configuration.access_key_id,
          @configuration.secret_access_key,
        )
      Aws::S3::Client.new(
        region: @configuration.region,
        credentials:,
      )
    end
  end

  class StorageConfiguration
    attr_reader :access_key_id, :secret_access_key, :bucket_name, :region

    def initialize(credentials)
      @access_key_id = credentials[:aws_access_key_id]
      @secret_access_key = credentials[:aws_secret_access_key]
      @bucket_name = credentials[:bucket_name]
      @region = credentials[:aws_region]
    end

    def ==(other)
      @access_key_id == other.access_key_id &&
        @secret_access_key == other.secret_access_key &&
        @bucket_name == other.bucket_name &&
        @region == other.region
    end
  end
end
