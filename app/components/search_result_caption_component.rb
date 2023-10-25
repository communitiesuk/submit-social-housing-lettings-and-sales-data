class SearchResultCaptionComponent < ViewComponent::Base
  attr_reader :searched, :count, :item_label, :total_count, :item, :filters_count

  def initialize(searched:, count:, item_label:, total_count:, item:, filters_count:)
    @searched = searched
    @count = count
    @item_label = item_label
    @total_count = total_count
    @item = item
    @filters_count = filters_count
    super
  end
end
