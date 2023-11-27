class AddMergeDateToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :merge_date, :datetime
  end
end
