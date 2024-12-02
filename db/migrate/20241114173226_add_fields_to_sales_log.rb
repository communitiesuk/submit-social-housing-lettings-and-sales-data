class AddFieldsToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :firststair, :integer
      t.column :numstair, :integer
      t.column :mrentprestaircasing, :decimal, precision: 10, scale: 2
      t.column :lasttransaction, :datetime
      t.column :initialpurchase, :datetime
    end
  end
end
