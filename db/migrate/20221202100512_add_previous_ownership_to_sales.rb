class AddPreviousOwnershipToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :prevown, :int
    end
  end
end
