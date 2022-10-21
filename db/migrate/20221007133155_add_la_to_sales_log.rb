class AddLaToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs do |t|
      t.column :la, :string
      t.column :la_known, :integer
    end
  end
end
