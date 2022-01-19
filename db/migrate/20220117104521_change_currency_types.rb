class ChangeCurrencyTypes < ActiveRecord::Migration[7.0]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :earnings
      t.column :earnings, :decimal, precision: 10, scale: 2
      t.remove :brent
      t.column :brent, :decimal, precision: 10, scale: 2
      t.remove :scharge
      t.column :scharge, :decimal, precision: 10, scale: 2
      t.remove :pscharge
      t.column :pscharge, :decimal, precision: 10, scale: 2
      t.remove :supcharg
      t.column :supcharg, :decimal, precision: 10, scale: 2
      t.remove :tcharge
      t.column :tcharge, :decimal, precision: 10, scale: 2
      t.remove :tshortfall
      t.column :tshortfall, :decimal, precision: 10, scale: 2
      t.remove :chcharge
      t.column :chcharge, :decimal, precision: 10, scale: 2
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.remove :earnings
      t.column :earnings, :integer
      t.remove :brent
      t.column :brent, :integer
      t.remove :scharge
      t.column :scharge, :integer
      t.remove :pscharge
      t.column :pscharge, :integer
      t.remove :supcharg
      t.column :supcharg, :integer
      t.remove :tcharge
      t.column :tcharge, :integer
      t.remove :tshortfall
      t.column :tshortfall, :integer
      t.remove :chcharge
      t.column :chcharge, :integer
    end
  end
end
