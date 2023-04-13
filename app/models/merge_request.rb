class MergeRequest < ApplicationRecord
  belongs_to :requesting_organisation, class_name: "Organisation"
  # has_many :merging_organisations, class_name: "Organisation", primary_key: "merging_organisation_ids", foreign_key: "id"
  # default_scope -> { select(column_names + ["merging_organisation_ids"]) }
  validate :validate_merging_organisations

  def merging_organisations
    Organisation.where(id: merging_organisation_ids)
  end

private

  def validate_merging_organisations
    if MergeRequest.where(requesting_organisation_id: merging_organisation_ids).count.positive?
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end

    if merging_organisation_ids&.any? { |org_id| MergeRequest.where("merging_organisation_ids @> ARRAY[?]", org_id).exists? }
      errors.add(:merging_organisation, I18n.t("validations.merge_request.organisation_part_of_another_merge"))
    end
  end
end
