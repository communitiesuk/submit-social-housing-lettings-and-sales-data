class MergeRequest < ApplicationRecord
  belongs_to :requesting_organisation, class_name: "Organisation"

  def merging_organisations
    Organisation.where(id: merging_organisation_ids)
  end
end
