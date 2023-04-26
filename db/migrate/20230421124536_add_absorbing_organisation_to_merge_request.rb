class AddAbsorbingOrganisationToMergeRequest < ActiveRecord::Migration[7.0]
  def change
    change_table :merge_requests, bulk: true do |t|
      t.column :absorbing_organisation_id, :integer
      t.column :new_absorbing_organisation, :boolean
    end
  end
end
