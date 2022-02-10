class RemoveCheckboxParentFields < ActiveRecord::Migration[7.0]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :accessibility_requirements
      t.remove :condition_effects
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.column :accessibility_requirements, :string
      t.column :condition_effects, :string
    end
  end
end
