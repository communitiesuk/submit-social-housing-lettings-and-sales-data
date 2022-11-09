class AddDeactivationDateToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :deactivation_date, :datetime
  end
end
