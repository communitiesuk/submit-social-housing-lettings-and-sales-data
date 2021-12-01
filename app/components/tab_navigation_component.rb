class TabNavigationComponent < ViewComponent::Base
  attr_reader :items

  def initialize(items:)
    @items = items
    super
  end

  def strip_query(url)
    url = Addressable::URI.parse(url)
    url.query_values = nil
    url.to_s
  end
end
