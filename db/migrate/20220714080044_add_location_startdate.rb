class AddLocationStartdate < ActiveRecord::Migration[7.0]
  def change
    change_table :locations, bulk: true do |t|
      t.column :startdate, :datetime
    end
  end
end
