class AddStartedAt < ActiveRecord::Migration[7.0]
  def change
    add_column :logs_exports, :started_at, :datetime
  end
end
