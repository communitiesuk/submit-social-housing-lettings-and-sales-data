class ChangeCurrencyTypes < ActiveRecord::Migration[7.0]
  def up
    change_column :case_logs, :earnings, :decimal, precision: 10, scale: 2
    change_column :case_logs, :brent, :decimal, precision: 10, scale: 2
    change_column :case_logs, :scharge, :decimal, precision: 10, scale: 2
    change_column :case_logs, :pscharge, :decimal, precision: 10, scale: 2
    change_column :case_logs, :supcharg, :decimal, precision: 10, scale: 2
    change_column :case_logs, :tcharge, :decimal, precision: 10, scale: 2
    change_column :case_logs, :tshortfall, :decimal, precision: 10, scale: 2
    change_column :case_logs, :chcharge, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :case_logs, :earnings, :integer
    change_column :case_logs, :brent, :integer
    change_column :case_logs, :scharge, :integer
    change_column :case_logs, :pscharge, :integer
    change_column :case_logs, :supcharg, :integer
    change_column :case_logs, :tcharge, :integer
    change_column :case_logs, :tshortfall, :integer
  end
end
