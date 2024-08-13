class RemoveNewOrgMergeRequestFields < ActiveRecord::Migration[7.0]
  def up
    change_table :merge_requests, bulk: true do |t|
      t.remove :new_absorbing_organisation
      t.remove :telephone_number_correct
      t.remove :new_telephone_number
      t.remove :new_organisation_name
      t.remove :new_organisation_address_line1
      t.remove :new_organisation_address_line2
      t.remove :new_organisation_postcode
      t.remove :new_organisation_telephone_number
    end
  end

  def down
    change_table :merge_requests, bulk: true do |t|
      t.column :new_absorbing_organisation, :boolean
      t.column :telephone_number_correct, :boolean
      t.column :new_telephone_number, :string
      t.column :new_organisation_name, :string
      t.column :new_organisation_address_line1, :string
      t.column :new_organisation_address_line2, :string
      t.column :new_organisation_postcode, :string
      t.column :new_organisation_telephone_number, :string
    end
  end
end
