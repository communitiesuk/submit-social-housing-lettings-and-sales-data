module ApplicationHelper
  def browser_title(title, *resources)
    if resources.any? { |r| r.present? && r.errors.present? }
      "Error: #{[title, t('service_name'), 'GOV.UK'].select(&:present?).join(' - ')}"
    else
      [title, t("service_name"), "GOV.UK"].select(&:present?).join(" - ")
    end
  end
end
