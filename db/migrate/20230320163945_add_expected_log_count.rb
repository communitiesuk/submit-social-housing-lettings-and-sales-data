class AddExpectedLogCount < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :expected_log_count, :integer
  end
end
