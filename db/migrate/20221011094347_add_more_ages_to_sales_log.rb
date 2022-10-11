class AddMoreAgesToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :age4, :integer
      t.column :age4_known, :integer
      t.column :age5, :integer
      t.column :age5_known, :integer
      t.column :age6, :integer
      t.column :age6_known, :integer
    end
  end
end
