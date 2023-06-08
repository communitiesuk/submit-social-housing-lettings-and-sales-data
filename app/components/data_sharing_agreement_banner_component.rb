class DataSharingAgreementBannerComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :user, :organisation

  def initialize(user:, organisation: nil)
    @user = user
    @organisation = organisation

    super
  end

  def display_banner?
    return false unless FeatureToggle.new_data_protection_confirmation?
    return false if user.is_dpo?
    return false if user.support? && organisation.blank?

    !DataProtectionConfirmation.exists?(
      organisation: (organisation.presence || user.organisation),
      confirmed: true,
    )
  end

  def data_sharing_agreement_href
    data_sharing_agreement_organisation_path(organisation.presence || user.organisation)
  end
end
