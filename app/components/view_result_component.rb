class ViewResultComponent < ViewComponent::Base
  attr_reader :searched, :count, :item_label, :total_count, :item, :request

  def initialize(searched:, count:, item_label:, total_count:, item:, request:)
    @searched = searched
    @count = count
    @item_label = item_label
    @total_count = total_count
    @item = item
    @request = request
    super
  end
end
