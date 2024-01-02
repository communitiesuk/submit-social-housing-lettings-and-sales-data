class AddLaInferredToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :is_la_inferred, :boolean
  end
end
