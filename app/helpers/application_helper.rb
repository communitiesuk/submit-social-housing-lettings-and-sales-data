module ApplicationHelper
  include Pagy::Frontend

  def browser_title(title, pagy, *resources)
    if resources.any? { |r| r.present? && r.errors.present? }
      "Error: #{[title, t('service_name'), 'GOV.UK'].select(&:present?).join(' - ')}"
    else
      [paginated_title(title, pagy), t("service_name"), "GOV.UK"].select(&:present?).join(" - ")
    end
  end

private

  def paginated_title(title, pagy)
    return unless title
    return title unless pagy && pagy.pages > 1

    title + " (page #{pagy.page} of #{pagy.pages})"
  end
end
