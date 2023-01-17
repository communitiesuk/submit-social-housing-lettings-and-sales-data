class AddDerivedHouseholdFields < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :hhmemb, :integer
      t.column :totadult, :integer
      t.column :totchild, :integer
      t.column :hhtype, :integer
    end
  end
end
