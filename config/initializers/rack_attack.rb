require "configuration/configuration_service"
require "configuration/paas_configuration_service"

if Rails.env.development? || Rails.env.test?
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  Rack::Attack.enabled = false
elsif Rails.env.review?
  redis_url = Configuration::PaasConfigurationService.new.redis_uris.to_a[0][1]
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: redis_url)
else
  redis_url = Configuration::PaasConfigurationService.new.redis_uris[:"dluhc-core-#{Rails.env}-redis"]
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: redis_url)
end

Rack::Attack.throttle("password reset requests", limit: 5, period: 60.seconds) do |request|
  if request.params["user"].present? && request.path == "/account/password" && request.post?
    request.params["user"]["email"].to_s.downcase.gsub(/\s+/, "")
  end
end

Rack::Attack.throttle("admin password reset requests", limit: 5, period: 60.seconds) do |request|
  if request.params["admin_user"].present? && request.path == "/admin/password" && request.post?
    request.params["admin_user"]["email"].to_s.downcase.gsub(/\s+/, "")
  end
end

Rack::Attack.throttled_responder = lambda do |_env|
  headers = {
    "Location" => "/429",
  }
  [301, headers, []]
end
