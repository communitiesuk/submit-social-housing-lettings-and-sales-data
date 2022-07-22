class AddLocationAdminDistrictToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :location_admin_district, :string
  end
end
