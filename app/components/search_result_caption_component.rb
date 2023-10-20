class SearchResultCaptionComponent < ViewComponent::Base
  attr_reader :searched, :count, :item_label, :total_count, :item, :path

  def initialize(searched:, count:, item_label:, total_count:, item:)
    @searched = searched
    @count = count
    @item_label = item_label
    @total_count = total_count
    @item = item
    super
  end
end
