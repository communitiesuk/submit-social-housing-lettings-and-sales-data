class AddDetailsKnown1ToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :details_known_1, :integer
    end
  end
end
