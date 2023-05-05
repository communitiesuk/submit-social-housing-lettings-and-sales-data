class AddNewOrganisationName < ActiveRecord::Migration[7.0]
  change_table :merge_requests, bulk: true do |t|
    t.column :new_organisation_name, :string
  end
end
