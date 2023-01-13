class AddPostcodeFieldsToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :postcode_known, :integer
      t.column :pcode1, :string
      t.column :pcode2, :string
      t.column :pcodenk, :integer
      t.column :postcode_full, :string
      t.column :is_la_inferred, :boolean
    end
  end
end
