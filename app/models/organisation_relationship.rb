class OrganisationRelationship < ApplicationRecord
  belongs_to :child_organisation, class_name: "Organisation"
  belongs_to :parent_organisation, class_name: "Organisation"
  validates :parent_organisation_id, presence: { message: "You must choose a housing provider" }
  validates :child_organisation_id, presence: { message: "You must choose a managing agent" }
  validates :parent_organisation_id, uniqueness: { scope: :child_organisation_id, message: "You have already added this housing provider" }
  validates :child_organisation_id, uniqueness: { scope: :parent_organisation_id, message: "You have already added this managing agent" }
  validate :validate_housing_provider_owns_stock, on: :housing_provider

private

  def validate_housing_provider_owns_stock
    if parent_organisation_id.present? && !parent_organisation.holds_own_stock
      errors.add :parent_organisation_id, I18n.t("validations.scheme.owning_organisation.does_not_own_stock")
    end
  end
end
