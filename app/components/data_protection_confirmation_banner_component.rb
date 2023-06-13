class DataProtectionConfirmationBannerComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :user, :organisation

  def initialize(user:, organisation: nil)
    @user = user
    @organisation = organisation

    super
  end

  def display_banner?
    return false unless FeatureToggle.new_data_protection_confirmation?
    return false if user.support? && organisation.blank?

    !DataProtectionConfirmation.exists?(
      organisation: org_or_user_org,
      confirmed: true,
    )
  end

  def data_protection_officers_text
    if org_or_user_org.data_protection_officers.any?
      "You can ask: #{org_or_user_org.data_protection_officers.map(&:name).join(', ')}"
    end
  end

  def data_sharing_agreement_href
    data_sharing_agreement_organisation_path(org_or_user_org)
  end

private

  def org_or_user_org
    organisation.presence || user.organisation
  end
end
