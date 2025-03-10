require "configuration/configuration_service"
require "configuration/env_configuration_service"

configuration_service = Configuration::EnvConfigurationService.new

if Rails.env.development? || Rails.env.test?
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  Rack::Attack.enabled = false
else
  redis_url = configuration_service.redis_uris.to_a[0][1]
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: redis_url)
end

Rack::Attack.throttle("password reset requests", limit: 5, period: 60.seconds) do |request|
  if request.params["user"].present? && request.path == "/account/password" && request.post?
    request.params["user"]["email"].to_s.downcase.gsub(/\s+/, "")
  end
end

Rack::Attack.throttled_responder = lambda do |_env|
  headers = {
    "Location" => "/429",
  }
  [301, headers, []]
end
