class AddWchchrgDerivedVariableField < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.decimal :wchchrg, precision: 10, scale: 2
    end
  end
end
