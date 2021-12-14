require "webmock/rspec"

module RequestHelper
  def self.stub_http_requests
    WebMock.disable_net_connect!(allow_localhost: true)
    WebMock.stub_request(:get, /api.postcodes.io/)
      .to_return(status: 200, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})
  end
end
