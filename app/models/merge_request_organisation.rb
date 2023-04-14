class MergeRequestOrganisation < ApplicationRecord
  belongs_to :merge_request, class_name: "MergeRequest"
  belongs_to :merging_organisation, class_name: "Organisation"
  validates :merge_request_id, presence: { message: I18n.t("validations.merge_request.merge_request_id.blank") }
  validates :merging_organisation_id, presence: { message: I18n.t("validations.merge_request.merging_organisation_id.blank") }
  validate :validate_merging_organisations

  has_paper_trail

private

  def validate_merging_organisations
    if MergeRequestOrganisation.where(merge_request_id:, merging_organisation_id:).count.positive?
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end

    if MergeRequestOrganisation.where.not(merge_request_id:).where(merging_organisation_id:).count.positive?
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
      merge_request.errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end

    if MergeRequest.where(requesting_organisation_id: merging_organisation_id).count.positive?
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
      merge_request.errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end

    if merging_organisation_id.blank? || !Organisation.where(id: merging_organisation_id).exists?
      merge_request.errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_not_selected"))
    end
  end
end
