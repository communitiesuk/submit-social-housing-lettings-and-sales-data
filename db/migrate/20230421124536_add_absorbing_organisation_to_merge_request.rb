class AddAbsorbingOrganisationToMergeRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :merge_requests, :absorbing_organisation_id, :integer
  end
end
