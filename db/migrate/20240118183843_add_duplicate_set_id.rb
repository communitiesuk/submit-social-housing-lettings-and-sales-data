class AddDuplicateSetId < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :duplicate_set_id, :integer
    add_column :sales_logs, :duplicate_set_id, :integer
  end
end
