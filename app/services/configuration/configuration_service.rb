module Configuration
  class ConfigurationService
    attr_reader :s3_buckets, :redis_uris

    def initialize(logger = Rails.logger)
      @logger = logger
      @config = read_config
      @s3_buckets = read_s3_buckets
      @redis_uris = read_redis_uris
    end

    def s3_config_present?
      config_present? && @config.key?(:"aws-s3-bucket")
    end

    def redis_config_present?
      config_present? && @config.key?(:redis)
    end

  private

    def config_present?
      raise NotImplementedError
    end

    def read_config
      raise NotImplementedError
    end

    def read_s3_buckets
      return {} unless s3_config_present?

      s3_buckets = {}
      @config[:"aws-s3-bucket"].each do |bucket_config|
        if bucket_config.key?(:instance_name)
          s3_buckets[bucket_config[:instance_name].to_sym] = bucket_config
        end
      end
      s3_buckets
    end

    def read_redis_uris
      return {} unless redis_config_present?

      redis_uris = {}
      @config[:redis].each do |redis_config|
        if redis_config.key?(:instance_name)
          redis_uris[redis_config[:instance_name].to_sym] = redis_config.dig(:credentials, :uri)
        end
      end
      redis_uris
    end
  end
end
