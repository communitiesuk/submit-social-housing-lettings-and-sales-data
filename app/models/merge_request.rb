class MergeRequest < ApplicationRecord
  belongs_to :requesting_organisation, class_name: "Organisation"
  # has_many :merging_organisations, class_name: "Organisation", primary_key: "merging_organisation_ids", foreign_key: "id"
  # default_scope -> { select(column_names + ["merging_organisation_ids"]) }

  def merging_organisations
    Organisation.where(id: merging_organisation_ids)
  end
end
