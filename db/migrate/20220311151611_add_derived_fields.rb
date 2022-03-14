class AddDerivedFields < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.decimal :wrent, precision: 10, scale: 2
      t.decimal :wscharge, precision: 10, scale: 2
      t.decimal :wpschrge, precision: 10, scale: 2
      t.decimal :wsupchrg, precision: 10, scale: 2
      t.decimal :wtcharge, precision: 10, scale: 2
      t.decimal :wtshortfall, precision: 10, scale: 2
    end
  end
end
