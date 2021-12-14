class AddDayMonthYearFieldsForStartDate < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :day, :integer
      t.column :month, :integer
      t.column :year, :integer
    end
  end
end
