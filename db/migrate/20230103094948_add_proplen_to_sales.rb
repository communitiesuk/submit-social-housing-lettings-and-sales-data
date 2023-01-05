class AddProplenToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :proplen, :integer
    end
  end
end
