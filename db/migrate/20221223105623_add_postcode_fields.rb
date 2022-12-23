class AddPostcodeFields < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :ppostcode_full, :string
      t.column :is_previous_la_inferred, :boolean
      t.column :ppcodenk, :integer
      t.column :ppostc1, :string
      t.column :ppostc2, :string
      t.column :prevloc, :string
    end
  end
end
