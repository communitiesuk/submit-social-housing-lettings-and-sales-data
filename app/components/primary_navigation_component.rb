class PrimaryNavigationComponent < ViewComponent::Base
  attr_reader :items

  def initialize(items:)
    @items = items
    Rails.env.production? ? @items = @items.reject { |nav_item| nav_item.text.include?("Supported housing") } : @items
    super
  end

  def highlighted_item?(item, _path)
    item[:current]
  end
end
