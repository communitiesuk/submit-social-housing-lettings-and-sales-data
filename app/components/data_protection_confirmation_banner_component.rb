class DataProtectionConfirmationBannerComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :user, :organisation

  def initialize(user:, organisation: nil)
    @user = user
    @organisation = organisation

    super
  end

  def display_banner?
    return false if user.support? && organisation.blank?
    return true if org_without_dpo?
    return false if !org_or_user_org.holds_own_stock? && org_or_user_org.stock_owners.empty? && org_or_user_org.absorbed_organisations.empty?

    !org_or_user_org.organisation_or_stock_owner_signed_dsa_and_holds_own_stock?
  end

  def header_text
    if org_without_dpo?
      "To create logs your organisation must state a data protection officer. They must sign the Data Sharing Agreement."
    elsif !org_or_user_org.holds_own_stock?
      "Your organisation does not own stock. To create logs your stock owner(s) must accept the Data Sharing Agreement on CORE."
    elsif user.is_dpo?
      "Your organisation must accept the Data Sharing Agreement before you can create any logs."
    else
      "Your data protection officer must accept the Data Sharing Agreement on CORE before you can create any logs."
    end
  end

  def banner_text
    if org_without_dpo? || user.is_dpo? || !org_or_user_org.holds_own_stock?
      govuk_link_to(
        link_text,
        link_href,
        class: "govuk-notification-banner__link govuk-!-font-weight-bold",
      )
    else
      tag.p data_protection_officers_text
    end
  end

private

  def data_protection_officers_text
    if org_or_user_org.data_protection_officers.any?
      "You can ask: #{org_or_user_org.data_protection_officers.map(&:name).sort_by(&:downcase).join(', ')}"
    end
  end

  def link_text
    if dpo_required?
      "Contact helpdesk to assign a data protection officer"
    elsif !org_or_user_org.holds_own_stock?
      "View or add stock owners"
    else
      "Read the Data Sharing Agreement"
    end
  end

  def link_href
    if dpo_required?
      GlobalConstants::HELPDESK_URL
    elsif !org_or_user_org.holds_own_stock?
      stock_owners_organisation_path(org_or_user_org)
    else
      data_sharing_agreement_organisation_path(org_or_user_org)
    end
  end

  def dpo_required?
    org_or_user_org.data_protection_officers.empty?
  end

  def org_or_user_org
    organisation.presence || user.organisation
  end

  def org_without_dpo?
    org_or_user_org.data_protection_officers.empty?
  end
end
