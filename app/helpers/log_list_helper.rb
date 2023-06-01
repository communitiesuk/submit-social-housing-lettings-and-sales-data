module LogListHelper
  def display_delete_logs?(current_user, search_term)
    if current_user.data_provider?
      filter_selected?("user", "yours")
    else
      any_filter_selected? || search_term.present?
    end
  end
end
