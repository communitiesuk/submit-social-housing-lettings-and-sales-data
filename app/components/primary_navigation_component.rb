class PrimaryNavigationComponent < ViewComponent::Base
  attr_reader :items

  def initialize(items:)
    @items = items
    super
  end

  def highlighted_tab?(item, _path)
    item[:current]
  end
end
