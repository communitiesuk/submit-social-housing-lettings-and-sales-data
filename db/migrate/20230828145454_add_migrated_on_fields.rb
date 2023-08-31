class AddMigratedOnFields < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :values_updated_at, :datetime
    add_column :sales_logs, :values_updated_at, :datetime
  end
end
