class AddEthnicFieldsForBuyer2 < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :ethnic_group2, :integer
      t.column :ethnicbuy2, :integer
    end
  end
end
