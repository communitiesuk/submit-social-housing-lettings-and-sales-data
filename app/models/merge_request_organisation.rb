class MergeRequestOrganisation < ApplicationRecord
  belongs_to :merge_request, class_name: "MergeRequest"
  belongs_to :merging_organisation, class_name: "Organisation"
  validates :merge_request_id, presence: { message: I18n.t("validations.organisation.stock_owner.blank") }
  validates :merging_organisation_id, presence: { message: I18n.t("validations.organisation.managing_agent.blank") }
  validate :validate_merging_organisations

  has_paper_trail

private

  def validate_merging_organisations
    if MergeRequestOrganisation.where(merge_request_id:, merging_organisation:).count.positive?
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end

    if MergeRequestOrganisation.where.not(merge_request_id:).where(merging_organisation_id: merging_organisation.id).count.positive?
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
      merge_request.errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end

    if MergeRequest.where(requesting_organisation: merging_organisation).count.positive?
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
      merge_request.errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end
  end
end
