module ToggleActiveSchemeHelper
  def toggle_scheme_form_path(action, scheme)
    if action == "deactivate"
      scheme_new_deactivation_path(scheme)
    else
      scheme_reactivate_path(scheme)
    end
  end

  def date_type_question(action)
    action == "deactivate" ? :deactivation_date_type : :reactivation_date_type
  end

  def date_question(action)
    action == "deactivate" ? :deactivation_date : :reactivation_date
  end
end
