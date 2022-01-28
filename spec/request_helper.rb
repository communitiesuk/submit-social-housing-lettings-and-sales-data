require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

module RequestHelper
  def self.stub_http_requests
    WebMock.stub_request(:get, /api.postcodes.io/)
      .to_return(status: 200, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})
    WebMock.stub_request(:post, /api.notifications.service.gov.uk\/v2\/notifications\/email/)
      .to_return(status: 200, body: "", headers: {})
  end
end
