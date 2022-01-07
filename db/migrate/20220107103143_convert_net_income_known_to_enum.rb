class ConvertNetIncomeKnownToEnum < ActiveRecord::Migration[7.0]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :net_income_known
      t.column :net_income_known, :integer
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.remove :net_income_known
      t.column :net_income_known, :string
    end
  end
end
