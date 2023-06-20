module LogListHelper
  def display_delete_logs?(current_user, search_term, filter_type)
    if current_user.data_provider?
      filter_selected?("user", "yours", filter_type)
    else
      any_filter_selected?(filter_type) || search_term.present?
    end
  end

  def in_organisations_tab?
    controller.class.name.start_with? "Organisation"
  end
end
