class MissingStockOwnersBannerComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :user, :organisation

  def initialize(user:)
    @user = user
    @organisation = user.organisation

    super
  end

  def display_banner?
    return false if user.support?
    return false if DataProtectionConfirmationBannerComponent.new(user:, organisation:).display_banner?

    !organisation.holds_own_stock? && organisation.stock_owners.empty? && organisation.absorbed_organisations.empty?
  end

  def header_text
    if user.data_coordinator?
      "Your organisation does not own stock. You must #{add_stock_owner_link} before you can create logs.".html_safe
    else
      "Your organisation does not own stock. You must add a stock owner before you can create logs.".html_safe
    end
  end

  def banner_text
    if user.data_coordinator?
      "If your organisation does own stock, #{contact_helpdesk_link} to update your details.".html_safe
    else
      "Ask a data coordinator to add a stock owner. Find your data coordinators on the #{users_link}.</br>
      If your organisation does own stock, #{contact_helpdesk_link} to update your details.".html_safe
    end
  end

private

  def add_stock_owner_link
    govuk_link_to(
      "add a stock owner",
      stock_owners_add_organisation_path(id: organisation.id),
      class: "govuk-notification-banner__link govuk-!-font-weight-bold",
    )
  end

  def contact_helpdesk_link
    govuk_link_to(
      "contact the helpdesk",
      GlobalConstants::HELPDESK_URL,
      class: "govuk-notification-banner__link govuk-!-font-weight-bold",
    )
  end

  def users_link
    govuk_link_to(
      "users page",
      users_path,
      class: "govuk-notification-banner__link govuk-!-font-weight-bold",
    )
  end
end
