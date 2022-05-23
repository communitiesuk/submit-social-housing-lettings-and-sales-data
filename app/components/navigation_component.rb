class NavigationComponent < ViewComponent::Base
  attr_reader :items, :level

  def initialize(items:, level: "primary")
    @items = items
    @level = level
    super
  end

  def highlighted_tab?(item, _path)
    item[:current]
  end
end
