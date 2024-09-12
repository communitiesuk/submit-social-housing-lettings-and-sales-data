class PostcodeService

  def lookup(postcode)
    # Avoid network calls when postcode is invalid
    return unless postcode.match(POSTCODE_REGEXP)

    result = nil
    begin
      # URI encoding only supports ASCII characters
      ascii_postcode = self.class.clean(postcode)
      response = Excon.get("https://api.postcodes.io/postcodes/#{ascii_postcode}", idempotent: true, timeout: 30, expects: [200])
      parsed_response = JSON.parse(response.body)
      result = {
        location_code: parsed_response["result"]["codes"]["admin_district"],
        location_admin_district: parsed_response["result"]["admin_district"],
      }
    rescue Excon::Error => e
      Rails.logger.warn("An error occurred with the postcode lookup request: #{e} #{e.response.body}")
    end
    result
  end

  def self.clean(postcode)
    postcode.encode("ASCII", "UTF-8", invalid: :replace, undef: :replace, replace: "").delete(" ").upcase
  end
end
