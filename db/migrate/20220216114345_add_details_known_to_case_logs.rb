class AddDetailsKnownToCaseLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :details_known_2, :integer
      t.column :details_known_3, :integer
      t.column :details_known_4, :integer
      t.column :details_known_5, :integer
      t.column :details_known_6, :integer
      t.column :details_known_7, :integer
      t.column :details_known_8, :integer
    end
  end
end
