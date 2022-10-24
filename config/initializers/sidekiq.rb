require "sidekiq/web"
require "sidekiq/cron/web"

if Rails.env.staging? || Rails.env.production?
  redis_url = Configuration::PaasConfigurationService.new.redis_uris[:"dluhc-core-#{Rails.env}-redis"]

  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end
end

# Until https://github.com/sidekiq-cron/sidekiq-cron/issues/357 is fixed.
Redis.silence_deprecations = true

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq::Cron::Job.load_from_hash YAML.load_file("config/sidekiq_cron_schedule.yml")
  end
end
