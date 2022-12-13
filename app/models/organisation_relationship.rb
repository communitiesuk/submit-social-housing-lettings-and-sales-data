class OrganisationRelationship < ApplicationRecord
  belongs_to :child_organisation, class_name: "Organisation"
  belongs_to :parent_organisation, class_name: "Organisation"
  validates :parent_organisation_id, presence: { message: I18n.t("validations.organisation.housing_provider.blank") }
  validates :child_organisation_id, presence: { message: I18n.t("validations.organisation.managing_agent.blank") }
  validates :parent_organisation_id, uniqueness: { scope: :child_organisation_id, message: I18n.t("validations.organisation.housing_provider.already_added") }
  validates :child_organisation_id, uniqueness: { scope: :parent_organisation_id, message: I18n.t("validations.organisation.managing_agent.already_added") }
  validate :validate_housing_provider_owns_stock, on: :housing_provider

private

  def validate_housing_provider_owns_stock
    if parent_organisation_id.present? && !parent_organisation.holds_own_stock
      errors.add :parent_organisation_id, I18n.t("validations.organisation.housing_provider.does_not_own_stock")
    end
  end
end
