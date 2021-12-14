class AddTotelder < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :totelder, :integer
    end
  end
end
