class AddMortgageLender < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :mortgagelender, :integer
      t.column :mortgagelenderother, :string
    end
  end
end
