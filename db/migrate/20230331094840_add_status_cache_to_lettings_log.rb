class AddStatusCacheToLettingsLog < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :status_cache, :integer, null: false, default: 0
  end
end
