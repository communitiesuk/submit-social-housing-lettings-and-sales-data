if Rails.env.staging? || Rails.env.production?
  redis_url = Configuration::PaasConfigurationService.new.redis_uris[:"dluhc-core-#{Rails.env}-redis"]

  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end
end
