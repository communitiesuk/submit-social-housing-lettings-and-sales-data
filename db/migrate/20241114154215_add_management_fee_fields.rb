class AddManagementFeeFields < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :has_management_fee, :integer
      t.column :management_fee, :decimal, precision: 10, scale: 2
    end
  end
end
