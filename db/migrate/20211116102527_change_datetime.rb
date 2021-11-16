class ChangeDatetime < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.remove :sale_completion_date
      t.column :sale_completion_date, :datetime
      t.remove :startdate
      t.column :startdate, :datetime
    end
  end
end
