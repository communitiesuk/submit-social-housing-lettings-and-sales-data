class AddPerson1AgeToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :age3, :integer
      t.column :age3_known, :integer
    end
  end
end
