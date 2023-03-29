class AddVisibleToLettingsLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :visible, :boolean, null: false, default: true

    add_index :lettings_logs, :visible
  end
end
