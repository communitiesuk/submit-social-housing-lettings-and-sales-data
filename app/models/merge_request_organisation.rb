class MergeRequestOrganisation < ApplicationRecord
  belongs_to :merge_request, class_name: "MergeRequest"
  belongs_to :merging_organisation, class_name: "Organisation"
  validates :merge_request, presence: { message: I18n.t("validations.merge_request.merge_request_id.blank") }
  validates :merging_organisation, presence: { message: I18n.t("validations.merge_request.merging_organisation_id.blank") }
  validate :validate_merging_organisations

  scope :merged, -> { joins(:merge_request).where(merge_requests: { status: "request_merged" }) }
  scope :with_merging_organisation, ->(merging_organisation) { where(merging_organisation:) }

  has_paper_trail

  def merging_organisation_name
    merging_organisation.name || ""
  end

private

  def validate_merging_organisations
    if MergeRequestOrganisation.where(merge_request:, merging_organisation:).count.positive?
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end

    if MergeRequestOrganisation.merged.with_merging_organisation(merging_organisation).count.positive?
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
      merge_request.errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end

    if merging_organisation_id.blank? || !Organisation.where(id: merging_organisation_id).exists?
      merge_request.errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_not_selected"))
    end
  end
end
