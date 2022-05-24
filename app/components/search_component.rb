class SearchComponent < ViewComponent::Base
  attr_reader :current_user, :search_label, :value

  def initialize(current_user:, search_label:, value: nil)
    @current_user = current_user
    @search_label = search_label
    @value = value
    super
  end

  def path(current_user)
    if request.path.include?("users")
      user_path(current_user)
    elsif request.path.include?("organisations") && request.path.include?("logs")
      request.path
    elsif request.path.include?("organisations")
      organisations_path
    elsif request.path.include?("logs")
      case_logs_path
    end
  end

private

  def user_path(current_user)
    current_user.support? ? users_path : users_organisation_path(current_user.organisation)
  end
end
