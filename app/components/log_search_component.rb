class LogSearchComponent < ViewComponent::Base
  attr_reader :current_user, :label

  def initialize(current_user:, label:)
    @current_user = current_user
    @label = label
    super
  end
end
