class AddSexesToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :sex4, :string
      t.column :sex5, :string
      t.column :sex6, :string
    end
  end
end
