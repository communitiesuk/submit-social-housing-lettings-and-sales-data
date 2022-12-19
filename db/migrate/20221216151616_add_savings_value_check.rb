class AddSavingsValueCheck < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :savings_value_check, :integer
      t.column :deposit_value_check, :integer
    end
  end
end
