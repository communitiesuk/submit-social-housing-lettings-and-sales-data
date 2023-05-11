module LogListHelper
  def display_delete_logs?
    if @current_user.data_provider?
      filter_selected?("user", "yours")
    else
      any_filter_selected? || @searched.present?
    end
  end
end
