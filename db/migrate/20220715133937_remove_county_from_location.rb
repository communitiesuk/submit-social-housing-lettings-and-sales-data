class RemoveCountyFromLocation < ActiveRecord::Migration[7.0]
  def change
    remove_column :locations, :county, :string
  end
end
