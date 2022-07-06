class AddUnitTypeSh < ActiveRecord::Migration[7.0]
  change_table :case_logs, bulk: true do |t|
    t.integer :unittype_sh
  end
end
