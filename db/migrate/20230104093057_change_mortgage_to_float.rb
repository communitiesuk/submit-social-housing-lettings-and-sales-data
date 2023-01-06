class ChangeMortgageToFloat < ActiveRecord::Migration[7.0]
  def self.up
    change_table :sales_logs do |t|
      t.change :mortgage, :decimal, precision: 10, scale: 2
    end
  end

  def self.down
    change_table :sales_logs do |t|
      t.change :mortgage, :integer
    end
  end
end
