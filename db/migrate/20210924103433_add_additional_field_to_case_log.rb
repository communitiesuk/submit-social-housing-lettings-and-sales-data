class AddAdditionalFieldToCaseLog < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :last_settled_home, :string
      t.column :benefit_cap_spare_room_subsidy, :string
      t.column :armed_forces_active, :string
      t.column :armed_forces_injured, :string
      t.column :armed_forces_partner, :string
      t.column :medical_conditions, :string
      t.column :pregnancy, :string
      t.column :accessibility_requirements, :string
      t.column :condition_effects, :string
    end
  end
end
