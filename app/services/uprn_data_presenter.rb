require "net/http"

class UprnDataPresenter
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def postcode
    data["POSTCODE"]
  end

  def address_line1
    data.values_at(
      "PO_BOX_NUMBER",
      "ORGANISATION_NAME",
      "DEPARTMENT_NAME",
      "SUB_BUILDING_NAME",
      "BUILDING_NAME",
      "BUILDING_NUMBER",
      "DEPENDENT_THOROUGHFARE_NAME",
      "THOROUGHFARE_NAME",
    ).compact
     .join(", ")
     .titleize
  end

  def address_line2
    data.values_at(
      "DOUBLE_DEPENDENT_LOCALITY", "DEPENDENT_LOCALITY"
    ).compact
     .join(", ")
     .titleize
     .presence
  end

  def town_or_city
    data["POST_TOWN"].titleize
  end
end
