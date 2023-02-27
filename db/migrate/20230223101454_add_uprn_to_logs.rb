class AddUprnToLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :uprn, :integer
      t.column :uprn_query, :integer
    end

    change_table :lettings_logs, bulk: true do |t|
      t.column :uprn, :integer
      t.column :uprn_query, :integer
    end
  end
end
