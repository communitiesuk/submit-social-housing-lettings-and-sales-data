class PrimaryNavigationComponent < ViewComponent::Base
  attr_reader :items

  def initialize(items:)
    @items = items
    super
  end

  def highlighted_tab?(item, path)
    item.fetch(:current, false) || item.fetch(:comparable_urls).any? { |url| path.include?(url) }
  end
end
