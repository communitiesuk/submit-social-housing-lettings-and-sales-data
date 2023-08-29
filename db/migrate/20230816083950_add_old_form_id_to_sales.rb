class AddOldFormIdToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.integer :old_form_id
    end
  end
end
