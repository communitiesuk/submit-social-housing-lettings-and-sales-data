module Storage
  class S3Service < StorageService
    attr_reader :configuration

    def initialize(config_service, paas_instance_name)
      super()
      @config_service = config_service
      @instance_name = (paas_instance_name || "").to_sym
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

    def create_configuration
      unless @config_service.s3_config_present?
        raise "No S3 bucket is present in the PaaS configuration"
      end
      unless @config_service.s3_buckets.key?(@instance_name)
        raise "#{@instance_name} instance name could not be found"
      end

      bucket_config = @config_service.s3_buckets[@instance_name]
      StorageConfiguration.new(bucket_config[:credentials])
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
