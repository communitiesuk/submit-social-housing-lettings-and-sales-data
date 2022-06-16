class PrimaryNavigationComponent < ViewComponent::Base
  attr_reader :items

  def initialize(items:)
    @items = items
    FeatureToggle.supported_housing_schemes_enabled? ? @items : @items.reject! { |nav_item| nav_item.text.include?("Schemes") }
    super
  end

  def highlighted_item?(item, _path)
    item[:current]
  end
end
