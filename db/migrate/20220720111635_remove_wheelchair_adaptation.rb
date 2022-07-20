class RemoveWheelchairAdaptation < ActiveRecord::Migration[7.0]
  def change
    remove_column :locations, :wheelchair_adaptation, :integer
  end
end
