class AddStaircaseFieldsToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :stairbought, :integer
      t.column :stairowned, :integer
    end
  end
end
