class ChangeDefaultValueForUserRole < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :role, 1
  end
end
