module Configuration
  class EnvConfigurationService < ConfigurationService
  private

    def config_present?
      !ENV["S3_CONFIG"].nil? || !ENV["REDIS_CONFIG"].nil?
    end

    def read_config
      unless config_present?
        @logger.warn("Could not find S3_CONFIG or REDIS_CONFIG in the environment variables!")
        return {}
      end

      config = {}
      assign_config(config, :"aws-s3-bucket", "S3_CONFIG")
      assign_config(config, :redis, "REDIS_CONFIG")
      config
    end

    def assign_config(config, symbol, env_variable)
      config_hash = parse_json_config(env_variable)
      config[symbol] = config_hash unless config_hash.empty?
    end

    def parse_json_config(env_variable_name)
      if ENV[env_variable_name].present?
        begin
          return JSON.parse(ENV[env_variable_name], { symbolize_names: true })
        rescue StandardError
          @logger.warn("Could not parse #{env_variable_name}!")
        end
      end
      {}
    end
  end
end
