module ApplicationHelper
  include Pagy::Frontend

  def browser_title(title, pagy, *resources)
    if resources.any? { |r| r.present? && r.errors.present? }
      "Error: #{[title, t('service_name'), 'GOV.UK'].select(&:present?).join(' - ')}"
    else
      [paginated_title(title, pagy), t("service_name"), "GOV.UK"].select(&:present?).join(" - ")
    end
  end

  def govuk_header_classes(current_user)
    if current_user&.support?
      "app-header app-header--orange"
    elsif (current_user.blank? || current_user.active_unread_notifications.present?) && !current_page?(notifications_path)
      "app-header app-header__no-border-bottom"
    else
      "app-header"
    end
  end

  def govuk_phase_banner_tag(current_user)
    if current_user&.support?
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
