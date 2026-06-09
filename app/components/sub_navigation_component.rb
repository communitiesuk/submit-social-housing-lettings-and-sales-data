class SubNavigationComponent < ViewComponent::Base
  attr_reader :items

  def initialize(items:)
    super()
    @items = items
  end

  def highlighted_item?(item, _path)
    item[:current]
  end
end
