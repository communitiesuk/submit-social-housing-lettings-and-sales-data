require "webmock/rspec"

module RequestHelper
  def self.stub_http_requests
    WebMock.disable_net_connect!(allow_localhost: true)
    WebMock.stub_request(:get, /api.postcodes.io/)
      .to_return(status: 200, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})

    WebMock.stub_request(:get, "https://api.postcodes.io/postcodes/AA11AA")
           .to_return(status: 200, body: "{\"status\":200,\"result\":{\"postcode\":\"AA1 1AA\",\"nuts\":\"Westminster\",\"codes\":{\"admin_district\":\"E09000033\"}}}", headers: {})

    WebMock.stub_request(:post, /api.notifications.service.gov.uk\/v2\/notifications\/email/)
      .to_return(status: 200, body: "", headers: {})
    WebMock.stub_request(:post, /api.notifications.service.gov.uk\/v2\/notifications\/sms/)
      .to_return(status: 200, body: "", headers: {})
  end

  def self.real_http_requests
    WebMock.allow_net_connect!
  end
end
