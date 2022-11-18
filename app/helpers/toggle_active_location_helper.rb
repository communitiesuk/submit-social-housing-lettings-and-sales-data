module ToggleActiveLocationHelper
  def toggle_location_form_path(action, location)
    if action == "deactivate"
      scheme_location_new_deactivation_path(location.scheme, location)
    else
      scheme_location_reactivate_path(location.scheme, location)
    end
  end

  def date_type_question(action)
    action == "deactivate" ? :deactivation_date_type : :reactivation_date_type
  end

  def date_question(action)
    action == "deactivate" ? :deactivation_date : :reactivation_date
  end
end
