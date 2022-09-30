class AddBuyer2RelationshipToBuyer1Column < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :relat2, :string
      t.column :otherrelat2, :string
    end
  end
end
