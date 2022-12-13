class AddPerson1RelationshipToBuyer1ToSalesLog < ActiveRecord::Migration[7.0]
  change_table :sales_logs, bulk: true do |t|
    t.column :relat3, :string
  end
end
