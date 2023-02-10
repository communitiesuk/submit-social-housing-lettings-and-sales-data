class AddPrevSharedToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :prevshared, :integer
    end
  end
end
