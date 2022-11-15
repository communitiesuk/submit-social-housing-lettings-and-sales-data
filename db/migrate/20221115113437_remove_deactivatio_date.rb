class RemoveDeactivatioDate < ActiveRecord::Migration[7.0]
  def up
    change_table :locations, bulk: true do |t|
      t.remove :deactivation_date
    end
  end

  def down
    change_table :locations, bulk: true do |t|
      t.column :deactivation_date, :datetime
    end
  end
end
