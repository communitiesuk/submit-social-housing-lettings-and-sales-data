class SearchComponent < ViewComponent::Base
  attr_reader :current_user, :label

  def initialize(current_user:, label:)
    @current_user = current_user
    @label = label
    super
  end

  def path(current_user)
    current_user.support? ? users_path : users_organisation_path(current_user.organisation)
  end
end
