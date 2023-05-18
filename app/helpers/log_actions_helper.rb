module LogActionsHelper
  include GovukLinkHelper

  def edit_actions_for_log(log)
    back = back_button_for(log)
    delete = delete_button_for_log(log)

    return if back.nil? && delete.nil?

    content_tag(:div, class: "govuk-button-group") do
      safe_join([back, delete])
    end
  end

  def create_lettings_log_button
    if FeatureToggle.not_started_status_removed?
      govuk_button_link_to "Create a new lettings log", lettings_log_path(id: "new"), class: "govuk-!-margin-right-6"
    else
      govuk_button_to "Create a new lettings log", lettings_logs_path, class: "govuk-!-margin-right-6"
    end
  end

  def create_lettings_log_for_org_button(org)
    # This doesn't work because it's a get request and can't old params like that
    if FeatureToggle.not_started_status_removed?
      govuk_button_link_to(
        "Create a new lettings log for this organisation",
        lettings_log_path(id: "new", lettings_log: { owning_organisation_id: org.id }),
      )
    else
      govuk_button_to(
        "Create a new lettings log for this organisation", lettings_logs_path(lettings_log: { owning_organisation_id: org.id }, method: :post)
      )
    end
  end

  def create_sales_log_button
    if FeatureToggle.not_started_status_removed?
      govuk_button_link_to "Create a new sales log", sales_log_path(id: "new"), class: "govuk-!-margin-right-6"
    else
      govuk_button_to "Create a new sales log", sales_logs_path, class: "govuk-!-margin-right-6"
    end
  end

  def create_sales_log_for_org_button(org)
    if FeatureToggle.not_started_status_removed?
      govuk_button_link_to(
        "Create a new sales log for this organisation",
        sales_logs_path(id: "new", sales_log: { owning_organisation_id: org.id }),
      )
    else
      govuk_button_to(
        "Create a new sales log for this organisation",
        sales_logs_path(sales_log: { owning_organisation_id: org.id }, method: :post),
      )
    end
  end

private

  def back_button_for(log)
    if log.completed?
      if log.bulk_uploaded?
        if log.lettings?
          govuk_button_link_to "Back to uploaded logs", resume_bulk_upload_lettings_result_path(log.bulk_upload)
        else
          govuk_button_link_to "Back to uploaded logs", resume_bulk_upload_sales_result_path(log.bulk_upload)
        end
      elsif log.lettings?
        govuk_button_link_to "Back to lettings logs", lettings_logs_path
      elsif log.sales?
        govuk_button_link_to "Back to sales logs", sales_logs_path
      end
    end
  end

  def policy_class_for(log)
    log.lettings? ? LettingsLogPolicy : SalesLogPolicy
  end

  def delete_button_for_log(log)
    if policy_class_for(log).new(current_user, log).destroy?
      govuk_button_link_to(
        "Delete log",
        log.lettings? ? lettings_log_delete_confirmation_path(log) : sales_log_delete_confirmation_path(log),
        warning: true,
      )
    end
  end
end
