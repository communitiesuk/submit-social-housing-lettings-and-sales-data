require "net/http"

class UprnClient
  attr_reader :uprn
  attr_accessor :error

  ADDRESS = "api.os.uk".freeze
  PATH = "/search/places/v1/uprn".freeze

  def initialize(uprn)
    @uprn = uprn
  end

  def call
    unless response.is_a?(Net::HTTPSuccess) && result.present?
      @error = "UPRN is not recognised. Check the number, or enter the address"
    end
  rescue JSON::ParserError
    @error = "UPRN is not recognised. Check the number, or enter the address"
  end

  def result
    @result ||= JSON.parse(response.body).dig("results", 0, "DPA")
  end

private

  def http_client
    client = Net::HTTP.new(ADDRESS, 443)
    client.use_ssl = true
    client.verify_mode = OpenSSL::SSL::VERIFY_PEER
    client.max_retries = 3
    client.read_timeout = 10 # seconds
    client
  end

  def endpoint_uri
    uri = URI(PATH)
    params = {
      uprn:,
      key: ENV["OS_DATA_KEY"],
    }
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def response
    @response ||= http_client.request_get(endpoint_uri)
  end
end
