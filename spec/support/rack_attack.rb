RSpec.configure do |config|
  config.include Rack::Test::Methods # , type: :component <- this bypasses the email empty, but cannot read last_response method
end
