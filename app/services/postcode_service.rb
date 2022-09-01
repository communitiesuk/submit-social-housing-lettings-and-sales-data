class PostcodeService
  def initialize
    @pio = Postcodes::IO.new
  end

  def lookup(postcode)
    # Avoid network calls when postcode is invalid
    return unless postcode.match(POSTCODE_REGEXP)

    postcode_lookup = nil
    begin
      # URI encoding only supports ASCII characters
      ascii_postcode = self.class.clean(postcode)
      Timeout.timeout(5) { postcode_lookup = @pio.lookup(ascii_postcode) }
    rescue Timeout::Error
      Rails.logger.warn("Postcodes.io lookup timed out")
    end
    if postcode_lookup && postcode_lookup.info.present?
      {
        location_code: postcode_lookup.codes["admin_district"],
        location_admin_district: postcode_lookup&.admin_district,
      }
    end
  end

  def self.clean(postcode)
    postcode.encode("ASCII", "UTF-8", invalid: :replace, undef: :replace, replace: "").delete(" ").upcase
  end
end
