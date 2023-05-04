class AddNewOrganisationAddress < ActiveRecord::Migration[7.0]
  def change
    change_table :merge_requests, bulk: true do |t|
      t.column :new_organisation_address_line1, :string
      t.column :new_organisation_address_line2, :string
      t.column :new_organisation_postcode, :string
    end
  end
end
