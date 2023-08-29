class AddMigratedOnFields < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :imported_at, :datetime
    add_column :sales_logs, :imported_at, :datetime
  end
end
