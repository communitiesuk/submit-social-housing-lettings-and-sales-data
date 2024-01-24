class DocumentListComponent < ViewComponent::Base
  attr_reader :items, :label

  def initialize(items:, label:)
    @items = items
    @label = label
    super
  end
end
