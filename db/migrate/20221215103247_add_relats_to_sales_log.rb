class AddRelatsToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :relat4, :string
      t.column :relat5, :string
      t.column :relat6, :string
    end
  end
end
