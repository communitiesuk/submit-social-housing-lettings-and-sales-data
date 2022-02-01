class PaasConfigurationService
  attr_reader :s3_buckets

  def initialize(logger = Rails.logger)
    @logger = logger
    @paas_config = read_pass_config
    @s3_buckets = read_s3_buckets
  end

  def config_present?
    !ENV["VCAP_SERVICES"].nil?
  end

  def s3_config_present?
    config_present? && @paas_config.key?(:"aws-s3-bucket")
  end

private

  def read_pass_config
    unless config_present?
      @logger.warn("Could not find VCAP_SERVICES in the environment!")
      return {}
    end

    begin
      JSON.parse(ENV["VCAP_SERVICES"], { symbolize_names: true })
    rescue StandardError
      @logger.warn("Could not parse VCAP_SERVICES!")
    end
  end

  def read_s3_buckets
    return {} unless s3_config_present?

    s3_buckets = {}
    @paas_config[:"aws-s3-bucket"].each do |bucket_config|
      if bucket_config.key?(:instance_name)
        s3_buckets[bucket_config[:instance_name].to_sym] = bucket_config
      end
    end
    s3_buckets
  end
end
