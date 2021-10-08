class AddAccessibilityFields < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :accessibility_requirements_fully_wheelchair_accessible_housing, :boolean
      t.column :accessibility_requirements_wheelchair_access_to_essential_rooms, :boolean
      t.column :accessibility_requirements_level_access_housing, :boolean
      t.column :accessibility_requirements_other_disability_requirements, :boolean
      t.column :accessibility_requirements_no_disability_requirements, :boolean
      t.column :accessibility_requirements_do_not_know, :boolean
      t.column :accessibility_requirements_prefer_not_to_say, :boolean
    end
  end
end
