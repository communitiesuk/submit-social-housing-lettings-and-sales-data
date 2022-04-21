class DocumentListComponent < ViewComponent::Base
  attr_reader :items

  def initialize(items:)
    @items = items
    super
  end
end
