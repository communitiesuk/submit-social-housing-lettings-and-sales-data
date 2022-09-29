class AddBuyer2AgeToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :age2, :integer
      t.column :age2_known, :integer
    end
  end
end
