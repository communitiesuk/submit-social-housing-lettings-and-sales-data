module ApplicationHelper
  def browser_title(title)
    if user_log_errors || case_log_errors || resource_errors
      "Error: #{[title, t('service_name'), 'GOV.UK'].select(&:present?).join(' - ')}"
    else
      [title, t("service_name"), "GOV.UK"].select(&:present?).join(" - ")
    end
  end

  def user_log_errors
    @user.present? && @user.errors.present?
  end

  def case_log_errors
    @case_log.present? && @case_log.errors.present?
  end

  def resource_errors
    @resource.present? && @resource.errors.present?
  end
end
