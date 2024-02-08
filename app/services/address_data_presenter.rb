require "net/http"

class AddressDataPresenter
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def uprn
    data["UPRN"]
  end

  def address
    data["ADDRESS"]
  end

  def match
    data["MATCH"]
  end

  def match_description
    data["MATCH_DESCRIPTION"]
  end
end
