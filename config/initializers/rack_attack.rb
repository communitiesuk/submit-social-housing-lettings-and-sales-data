Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
Rack::Attack.enabled = false

Rack::Attack.throttle("password reset requests", limit: 5, period: 60.seconds) do |request|
  if request.params["user"].present? && request.path == "/users/password" && request.post?
    request.params["user"]["email"].to_s.downcase.gsub(/\s+/, "")
  end
end
