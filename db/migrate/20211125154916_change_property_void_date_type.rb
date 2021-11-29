class ChangePropertyVoidDateType < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :property_void_date
      t.column :property_void_date, :datetime
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.remove :property_void_date
      t.column :property_void_date, :string
    end
  end
end
