module Configuration
  class PaasConfigurationService < ConfigurationService
  private

    def config_present?
      !ENV["VCAP_SERVICES"].nil?
    end

    def read_config
      unless config_present?
        @logger.warn("Could not find VCAP_SERVICES in the environment variables!")
        return {}
      end

      begin
        JSON.parse(ENV["VCAP_SERVICES"], { symbolize_names: true })
      rescue StandardError
        @logger.warn("Could not parse VCAP_SERVICES!")
        {}
      end
    end
  end
end
