class DataSharingAgreementBannerComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :user, :organisation

  def initialize(user:, organisation: nil)
    @user = user
    @organisation = organisation

    super
  end

  def display_banner?
    return false unless FeatureToggle.new_data_sharing_agreement?
    return false if user.is_dpo?
    return false if user.support? && organisation.blank?

    if organisation.present?
      !DataSharingAgreement.exists?(organisation:)
    else
      !DataSharingAgreement.exists?(organisation: user.organisation)
    end
  end

  def data_sharing_agreement_href
    data_sharing_agreement_organisation_path(organisation.presence || user.organisation)
  end
end
