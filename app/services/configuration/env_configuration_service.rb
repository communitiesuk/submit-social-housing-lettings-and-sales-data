module Configuration
  class EnvConfigurationService < ConfigurationService
  private

    def config_present?
      raise NotImplementedError
    end

    def read_config
      raise NotImplementedError
    end
  end
end
