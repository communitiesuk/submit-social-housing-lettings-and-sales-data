# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

map DataCollector::Application.config.relative_url_root || "/" do
  Timecop.travel(2025, 1, 1)
  run Rails.application
  Rails.application.load_server
end
