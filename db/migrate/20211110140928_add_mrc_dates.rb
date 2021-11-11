class AddMrcDates < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :property_major_repairs_date
      t.column :mrcdate, :datetime
      t.column :mrcday, :integer
      t.column :mrcmonth, :integer
      t.column :mrcyear, :integer
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.column :property_major_repairs_date, :string
      t.remove :mrcdate
      t.remove :mrcday
      t.remove :mrcmonth
      t.remove :mrcyear
    end
  end
end
