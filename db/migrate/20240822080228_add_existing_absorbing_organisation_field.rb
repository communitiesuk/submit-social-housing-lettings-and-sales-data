class AddExistingAbsorbingOrganisationField < ActiveRecord::Migration[7.0]
  def change
    add_column :merge_requests, :existing_absorbing_organisation, :boolean
  end
end
