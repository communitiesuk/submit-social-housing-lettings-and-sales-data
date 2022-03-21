require "paas_configuration_service"

if Rails.env.development? || Rails.env.test?
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  Rack::Attack.enabled = false
else
  redis_url = PaasConfigurationService.new.redis_uris[:"dluhc-core-#{Rails.env}-redis-rate-limit"]
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
