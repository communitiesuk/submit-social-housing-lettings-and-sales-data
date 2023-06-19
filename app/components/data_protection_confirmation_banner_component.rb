class DataProtectionConfirmationBannerComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :user, :organisation

  HELPDESK_URL = "https://digital.dclg.gov.uk/jira/servicedesk/customer/portal/4/group/21".freeze

  def initialize(user:, organisation: nil)
    @user = user
    @organisation = organisation

    super
  end

  def display_banner?
    return false unless FeatureToggle.new_data_protection_confirmation?
    return false if user.support? && organisation.blank?
    return true if org_without_dpo?

    !org_or_user_org.data_protection_confirmed?
  end

  def header_text
    if org_without_dpo?
      "To create logs your organisation must state a data protection officer. They must sign the Data Sharing Agreement."
    elsif user.is_dpo?
      "Your organisation must accept the Data Sharing Agreement before you can create any logs."
    else
      "Your data protection officer must accept the Data Sharing Agreement on CORE before you can create any logs."
    end
  end

  def second_row
    if org_without_dpo? || user.is_dpo?
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
    else
      "Read the Data Sharing Agreement"
    end
  end

  def link_href
    dpo_required? ? HELPDESK_URL : data_sharing_agreement_organisation_path(org_or_user_org)
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
