class AddressClient
  attr_reader :address, :uprn
  attr_accessor :error

  ADDRESS = "api.os.uk".freeze
  PATH_FIND = "/search/places/v1/find".freeze
  PATH_UPRN = "/search/places/v1/uprn".freeze

  def initialize(address: nil, uprn: nil)
    @address = address
    @uprn = uprn
  end

  def call
    unless response.is_a?(Net::HTTPSuccess) && result.present?
      @error = "Address is not recognised. Check the address, or enter the UPRN"
    end
  rescue JSON::ParserError
    @error = "Address is not recognised. Check the address, or enter the UPRN"
  end

  def result
    if response.is_a?(Net::HTTPSuccess)
      @result ||= JSON.parse(response.body)["results"]&.map { |address| address["DPA"] }
    else
      @result = nil
    end
  end

  def result_by_uprn
    if response.is_a?(Net::HTTPSuccess)
      @result ||= JSON.parse(response.body)["result"]
    else
      @result = nil
    end
  end

  private

  def http_client
    client = Net::HTTP.new(ADDRESS, 443)
    client.use_ssl = true
    client.verify_mode = OpenSSL::SSL::VERIFY_PEER
    client.max_retries = 3
    client.read_timeout = 30 # seconds
    client
  end

  def endpoint_uri
    uri = URI(PATH_FIND)
    params = {
      query: address,
      key: ENV["OS_DATA_KEY"],
      maxresults: 10,
      minmatch: 0.4,
    }
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def endpoint_uri_by_uprn
    uri = URI(PATH_UPRN)
    params = {
      uprn: uprn,
      key: ENV["OS_DATA_KEY"],
    }
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def response
    @response ||= http_client.request_get(address ? endpoint_uri : endpoint_uri_by_uprn)
  end
end
