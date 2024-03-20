class AddRelationshipValueCheckFields < ActiveRecord::Migration[7.0]
  def change
    change_table :lettings_logs, bulk: true do |t|
      t.column :partner_under_16_value_check, :integer
      t.column :multiple_partners_value_check, :integer
    end

    change_table :sales_logs, bulk: true do |t|
      t.column :partner_under_16_value_check, :integer
      t.column :multiple_partners_value_check, :integer
    end
  end
end
