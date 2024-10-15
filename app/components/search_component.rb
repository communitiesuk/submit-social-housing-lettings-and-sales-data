class SearchComponent < ViewComponent::Base
  attr_reader :current_user, :search_label, :value

  def initialize(current_user:, search_label:, value: nil)
    @current_user = current_user
    @search_label = search_label
    @value = value
    super
  end

  def path(current_user)
    return request.path if matching_path_conditions?

    if request.path.include?("users")
      user_path(current_user)
    elsif request.path.include?("organisations")
      organisations_path
    elsif request.path.include?("sales-logs")
      sales_logs_path
    elsif request.path.include?("logs")
      lettings_logs_path
    end
  end

private

  def user_path(current_user)
    current_user.support? ? users_path : users_organisation_path(current_user.organisation)
  end

  def matching_path_conditions?
    [
      %r{organisations/\d+/users},
      %r{organisations/\d+/lettings-logs},
      %r{organisations/\d+/sales-logs},
      %r{organisations/\d+/schemes},
      %r{organisations/\d+/stock-owners},
      %r{organisations/\d+/managing-agents},
      %r{sales-logs/bulk-uploads},
      %r{lettings-logs/bulk-uploads},
    ].any? { |pattern| request.path.match?(pattern) }
  end
end
