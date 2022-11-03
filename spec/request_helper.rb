require "webmock/rspec"

module RequestHelper
  def self.stub_http_requests
    WebMock.disable_net_connect!(allow_localhost: true)
    WebMock.stub_request(:get, /api.postcodes.io/)
      .to_return(status: 200, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})

    WebMock.stub_request(:get, "https://api.postcodes.io/postcodes/AA11AA")
           .to_return(status: 200, body: "{\"status\":200,\"result\":{\"postcode\":\"AA1 1AA\", \"outcode\": \"AA1\", \"incode\": \"1AA\", \"admin_district\":\"Westminster\",\"codes\":{\"admin_district\":\"E09000033\"}}}", headers: {})
    WebMock.stub_request(:get, "https://api.postcodes.io/postcodes/AA12AA")
           .to_return(status: 200, body: "{\"status\":200,\"result\":{\"postcode\":\"AA1 2AA\", \"outcode\": \"AA1\", \"incode\": \"2AA\", \"admin_district\":\"Westminster\",\"codes\":{\"admin_district\":\"E09000033\"}}}", headers: {})
    WebMock.stub_request(:get, "https://api.postcodes.io/postcodes/NW1L5DP")
           .to_return(status: 200, body: "{\"status\":200,\"result\":{\"postcode\":\"NW1L 5DP\", \"outcode\": \"NW1L\", \"incode\": \"5DP\", \"admin_district\":\"Westminster\",\"codes\":{\"admin_district\":\"E09000033\"}}}", headers: {})
    WebMock.stub_request(:get, "https://api.postcodes.io/postcodes/ZZ11ZZ")
           .to_return(status: 200, body: "{\"status\":200,\"result\":{\"postcode\":\"ZZ1 1ZZ\", \"outcode\": \"ZZ1\", \"incode\": \"1ZZ\", \"admin_district\":\"Westminster\",\"codes\":{\"admin_district\":\"E09000033\"}}}", headers: {})

    WebMock.stub_request(:post, /api.notifications.service.gov.uk\/v2\/notifications\/email/)
      .to_return(status: 200, body: "", headers: {})
    WebMock.stub_request(:post, /api.notifications.service.gov.uk\/v2\/notifications\/sms/)
      .to_return(status: 200, body: "", headers: {})
  end

  def self.real_http_requests
    WebMock.allow_net_connect!
  end
end
