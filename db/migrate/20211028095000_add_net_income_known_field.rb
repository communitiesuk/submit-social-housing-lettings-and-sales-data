class AddNetIncomeKnownField < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :net_income_known, :string
    end
  end
end
