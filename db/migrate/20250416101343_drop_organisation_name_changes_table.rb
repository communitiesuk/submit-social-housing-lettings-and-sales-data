class DropOrganisationNameChangesTable < ActiveRecord::Migration[7.2]
  def change
    drop_table :organisation_name_changes, if_exists: true
  end
end
