class AddAvailableFromToOrg < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :available_from, :datetime
  end
end
