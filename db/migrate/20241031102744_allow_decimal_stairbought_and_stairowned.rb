class AllowDecimalStairboughtAndStairowned < ActiveRecord::Migration[7.0]
  def up
    change_table :sales_logs, bulk: true do |t|
      t.change :stairbought, :decimal
      t.change :stairowned, :decimal
    end
  end

  def down
    change_table :sales_logs, bulk: true do |t|
      t.change :stairbought, :integer
      t.change :stairowned, :integer
    end
  end
end
