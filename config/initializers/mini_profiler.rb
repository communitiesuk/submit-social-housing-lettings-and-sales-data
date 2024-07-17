require "configuration/configuration_service"
require "configuration/env_configuration_service"

# set RedisStore
if Rails.env.staging?
  configuration_service = Configuration::EnvConfigurationService.new
  redis_url = configuration_service.redis_uris.to_a[0][1]

  Rack::MiniProfiler.config.storage_options = { url: redis_url }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
end
