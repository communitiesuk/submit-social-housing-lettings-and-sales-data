module ToggleActiveOrganisationHelper
  def toggle_organisation_form_path(action, organisation)
    if action == "deactivate"
      organisation_new_deactivation_path(organisation)
    else
      organisation_reactivate_path(organisation)
    end
  end

  def date_type_question(action)
    action == "deactivate" ? :deactivation_date_type : :reactivation_date_type
  end
end
