class DocumentListComponent < ViewComponent::Base
  attr_reader :items, :label

  def initialize(items:, label:)
    super()
    @items = items
    @label = label
  end
end
