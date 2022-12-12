class OrganisationRelationship < ApplicationRecord
  belongs_to :child_organisation, class_name: "Organisation"
  belongs_to :parent_organisation, class_name: "Organisation"
  validate :validate_housing_provider_relationship, on: :housing_provider
  validate :validate_managing_agent_relationship, on: :managing_agent

private

  def validate_housing_provider_relationship
    if parent_organisation_id.blank?
      errors.add :related_organisation_id, "You must choose a housing provider"
    elsif OrganisationRelationship.exists?(child_organisation:, parent_organisation:)
      errors.add :related_organisation_id, "You have already added this housing provider"
    elsif parent_organisation_id.present? && !parent_organisation.holds_own_stock
      errors.add :related_organisation_id, I18n.t("validations.scheme.owning_organisation.does_not_own_stock")
    end
  end

  def validate_managing_agent_relationship
    if child_organisation_id.blank?
      errors.add :related_organisation_id, "You must choose a managing agent"
    elsif OrganisationRelationship.exists?(child_organisation:, parent_organisation:)
      errors.add :related_organisation_id, "You have already added this managing agent"
    end
  end
end
