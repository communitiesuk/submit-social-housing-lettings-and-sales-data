require "webmock/rspec"

module RequestHelper
  def self.stub_http_requests
    WebMock.disable_net_connect!(allow_localhost: true)
    WebMock.stub_request(:get, /api.os.uk/)
      .to_return(status: 200, body: "{\"header\": {\"totalresults\": \"0\"}}", headers: {})
  end
end
