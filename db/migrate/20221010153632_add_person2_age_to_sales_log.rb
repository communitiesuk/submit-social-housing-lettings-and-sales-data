class AddPerson2AgeToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :age4, :integer
      t.column :age4_known, :integer
    end
  end
end
