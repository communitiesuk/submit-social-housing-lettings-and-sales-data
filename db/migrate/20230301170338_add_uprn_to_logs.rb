class AddUprnToLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :uprn, :string
      t.column :uprn_known, :integer
      t.column :uprn_confirmed, :integer
    end

    change_table :lettings_logs, bulk: true do |t|
      t.column :uprn, :string
      t.column :uprn_known, :integer
      t.column :uprn_confirmed, :integer
    end
  end
end
