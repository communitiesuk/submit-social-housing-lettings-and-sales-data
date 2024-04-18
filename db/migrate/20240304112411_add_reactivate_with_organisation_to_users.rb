class AddReactivateWithOrganisationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :reactivate_with_organisation, :boolean
  end
end
