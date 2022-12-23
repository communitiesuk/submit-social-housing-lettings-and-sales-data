class AddBuyersOrganisationsToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :pregyrha, :int
      t.column :pregla, :int
      t.column :pregghb, :int
      t.column :pregother, :integer
    end
  end
end
