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
    return true if show_no_dpo_message?
    return false if !org_or_user_org.holds_own_stock? && org_or_user_org.stock_owners.empty? && org_or_user_org.absorbed_organisations.empty?

    !dsa_signed? || !org_or_user_org.organisation_or_stock_owner_signed_dsa_and_holds_own_stock?
  end

  def header_text
    if show_no_dpo_message?
      "To create logs your organisation must state a data protection officer. They must sign the Data Sharing Agreement."
    elsif show_no_stock_owner_message?
      "Your organisation does not own stock. To create logs your stock owner(s) must accept the Data Sharing Agreement on CORE."
    elsif user.is_dpo?
      "Your organisation must accept the Data Sharing Agreement before you can create any logs."
    else
      "Your data protection officer must accept the Data Sharing Agreement on CORE before you can create any logs."
    end
  end

  def banner_text
    if show_no_dpo_message? || user.is_dpo? || !org_or_user_org.holds_own_stock?
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
    if show_no_dpo_message?
      "Contact helpdesk to assign a data protection officer"
    elsif show_no_stock_owner_message?
      "View or add stock owners"
    else
      "Read the Data Sharing Agreement"
    end
  end

  def link_href
    if show_no_dpo_message?
      GlobalConstants::HELPDESK_URL
    elsif show_no_stock_owner_message?
      stock_owners_organisation_path(org_or_user_org)
    else
      data_sharing_agreement_organisation_path(org_or_user_org)
    end
  end

  def show_no_dpo_message?
    # it is fine if an org has a DSA and the DPO has moved on
    # CORE staff do this sometimes as a single DPO covers multiple 'orgs' that exist as branches of the same real world org
    # so, they move the DPO to all the mini orgs and have them sign each DSA
    # so the DSA being signed can silence this warning
    org_or_user_org.data_protection_officers.empty? && !dsa_signed?
  end

  def dsa_signed?
    org_or_user_org.data_protection_confirmed?
  end

  def show_no_stock_owner_message?
    !org_or_user_org.holds_own_stock? && dsa_signed?
  end

  def org_or_user_org
    organisation.presence || user.organisation
  end
end
