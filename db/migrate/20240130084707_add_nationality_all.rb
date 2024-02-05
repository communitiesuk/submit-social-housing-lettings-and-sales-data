class AddNationalityAll < ActiveRecord::Migration[7.0]
  def change
    change_table :lettings_logs, bulk: true do |t|
      t.column :nationality_all, :integer
      t.column :nationality_all_group, :integer
    end
    change_table :sales_logs, bulk: true do |t|
      t.column :nationality_all, :integer
      t.column :nationality_all_group, :integer
      t.column :nationality_all_buyer2, :integer
      t.column :nationality_all_buyer2_group, :integer
    end
  end
end
