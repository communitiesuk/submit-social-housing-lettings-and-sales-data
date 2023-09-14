class AddChargesValueChecks < ActiveRecord::Migration[7.0]
  def change
    change_table :lettings_logs, bulk: true do |t|
      t.column :supcharg_value_check, :integer
      t.column :scharge_value_check, :integer
      t.column :pscharge_value_check, :integer
    end
  end
end
