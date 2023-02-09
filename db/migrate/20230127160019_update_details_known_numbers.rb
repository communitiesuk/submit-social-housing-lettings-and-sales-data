class UpdateDetailsKnownNumbers < ActiveRecord::Migration[7.0]
  def up
    change_table :sales_logs, bulk: true do |t|
      t.remove :details_known_1
      t.column :details_known_5, :integer
      t.column :details_known_6, :integer
    end
  end

  def down
    change_table :sales_logs, bulk: true do |t|
      t.column :details_known_1, :integer
      t.remove :details_known_5
      t.remove :details_known_6
    end
  end
end
