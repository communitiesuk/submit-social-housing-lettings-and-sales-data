require "net/http"

class AddressDataPresenter
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def uprn
    data["UPRN"]
  end

  def address_line1
    [data["SUB_BUILDING_NAME"], data["BUILDING_NUMBER"], data["BUILDING_NAME"], data["THOROUGHFARE_NAME"]].compact.join(", ")
  end

  def address_line2
    data["DEPENDENT_LOCALITY"]
  end

  def town_or_city
    data["POST_TOWN"]
  end

  def postcode
    data["POSTCODE"]
  end

  def address
    data["ADDRESS"]
  end
end
