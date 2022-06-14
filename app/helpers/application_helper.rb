module ApplicationHelper
  include Pagy::Frontend

  def browser_title(title, pagy, *resources)
    if resources.any? { |r| r.present? && r.errors.present? }
      "Error: #{[title, t('service_name'), 'GOV.UK'].select(&:present?).join(' - ')}"
    else
      [paginated_title(title, pagy), t("service_name"), "GOV.UK"].select(&:present?).join(" - ")
    end
  end

  def govuk_header_classes
    if current_user && current_user.support?
      "app-header app-header--orange"
    else
      "app-header"
    end
  end

  def govuk_phase_banner_tag
    if current_user && current_user.support?
      { colour: "orange", text: "Support beta" }
    else
      { text: "Beta" }
    end
  end

private

  def paginated_title(title, pagy)
    return unless title
    return title unless pagy && pagy.pages > 1

    title + " (page #{pagy.page} of #{pagy.pages})"
  end
end
