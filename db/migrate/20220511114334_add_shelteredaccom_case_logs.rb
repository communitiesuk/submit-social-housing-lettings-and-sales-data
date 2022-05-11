class AddShelteredaccomCaseLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :shelteredaccom, :integer
  end
end
