class AddAccessibilityRequirementsFields < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :housingneeds_type, :integer
      t.column :housingneeds_other, :integer
    end
  end
end
