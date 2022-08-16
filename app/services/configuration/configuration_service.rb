module Configuration
  class ConfigurationService
    attr_reader :s3_buckets, :redis_uris

    def s3_config_present?
      raise NotImplementedError
    end

    def redis_config_present?
      raise NotImplementedError
    end
  end
end
