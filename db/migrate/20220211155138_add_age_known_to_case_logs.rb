class AddAgeKnownToCaseLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :age1_known, :integer
      t.column :age2_known, :integer
      t.column :age3_known, :integer
      t.column :age4_known, :integer
      t.column :age5_known, :integer
      t.column :age6_known, :integer
      t.column :age7_known, :integer
      t.column :age8_known, :integer
    end
  end
end
