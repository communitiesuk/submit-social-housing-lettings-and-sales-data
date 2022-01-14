class AdditionalOrgFields < ActiveRecord::Migration[7.0]
  def up
    change_table :organisations, bulk: true do |t|
      t.column :active, :boolean
      t.column :old_association_type, :integer
      t.column :software_supplier_id, :string
      t.column :housing_management_system, :string
      t.column :choice_based_lettings, :boolean
      t.column :common_housing_register, :boolean
      t.column :choice_allocation_policy, :boolean
      t.column :cbl_proportion_percentage, :integer
      t.column :enter_affordable_logs, :boolean
      t.column :owns_affordable_logs, :boolean
      t.column :housing_registration_no, :string
      t.column :general_needs_units, :integer
      t.column :supported_housing_units, :integer
      t.column :unspecified_units, :integer
      t.column :old_org_id, :string
      t.column :old_visible_id, :integer
      t.change :phone, :string
    end
  end

  def down
    change_table :organisations, bulk: true do |t|
      t.remove :active
      t.remove :old_association_type
      t.remove :software_supplier_id
      t.remove :housing_management_system
      t.remove :choice_based_lettings
      t.remove :common_housing_register
      t.remove :choice_allocation_policy
      t.remove :cbl_proportion_percentage
      t.remove :enter_affordable_logs
      t.remove :owns_affordable_logs
      t.remove :housing_registration_no
      t.remove :general_needs_units
      t.remove :supported_housing_units
      t.remove :unspecified_units
      t.remove :old_org_id
      t.remove :old_visible_id
      t.change :phone, "integer USING phone::integer"
    end
  end
end
