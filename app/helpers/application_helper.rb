module ApplicationHelper
  def browser_title(title)
    [title, t("service_name"), "GOV.UK"].select(&:present?).join(" - ")
  end
end
