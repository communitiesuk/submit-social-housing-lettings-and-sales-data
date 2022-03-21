class AddVoidDateDayMonthYearFields < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :vday, :integer
      t.column :vmonth, :integer
      t.column :vyear, :integer
    end
  end
end
