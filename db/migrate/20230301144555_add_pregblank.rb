class AddPregblank < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :pregblank, :integer
  end
end
