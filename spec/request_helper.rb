require "webmock/rspec"

module RequestHelper
  def self.stub_http_requests
    WebMock.disable_net_connect!(allow_localhost: true)
    WebMock.stub_request(:get, /api.postcodes.io/)
      .to_return(status: 200, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})

    uri = "https://api.postcodes.io/postcodes/AA11AA"
    WebMock.stub_request(:get, uri)
           .to_return(status: 200, body: "{\"status\":200,\"result\":{\"postcode\":\"AA1 1AA\",\"quality\":1,\"eastings\":529922,\"northings\":179094,\"country\":\"England\",\"nhs_ha\":\"London\",\"longitude\":-0.12981,\"latitude\":51.495867,\"european_electoral_region\":\"London\",\"primary_care_trust\":\"Westminster\",\"region\":\"London\",\"lsoa\":\"Westminster 020C\",\"msoa\":\"Westminster 020\",\"incode\":\"4DF\",\"outcode\":\"SW1P\",\"parliamentary_constituency\":\"Cities of London and Westminster\",\"admin_district\":\"Westminster\",\"parish\":\"Westminster, unparished area\",\"admin_county\":null,\"admin_ward\":\"St James's\",\"ced\":null,\"ccg\":\"NHS North West London\",\"nuts\":\"Westminster\",\"codes\":{\"admin_district\":\"E09000033\",\"admin_county\":\"E99999999\",\"admin_ward\":\"E05000644\",\"parish\":\"E43000236\",\"parliamentary_constituency\":\"E14000639\",\"ccg\":\"E38000256\",\"ccg_id\":\"W2U3Z\",\"ced\":\"E99999999\",\"nuts\":\"TLI32\",\"lsoa\":\"E01004733\",\"msoa\":\"E02000979\",\"lau2\":\"E09000033\"}}}", headers: {})

    WebMock.stub_request(:post, /api.notifications.service.gov.uk\/v2\/notifications\/email/)
      .to_return(status: 200, body: "", headers: {})
    WebMock.stub_request(:post, /api.notifications.service.gov.uk\/v2\/notifications\/sms/)
      .to_return(status: 200, body: "", headers: {})
  end

  def self.real_http_requests
    WebMock.allow_net_connect!
  end
end
