class AddValuesUpdatedAtToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :values_updated_at, :datetime
  end
end
