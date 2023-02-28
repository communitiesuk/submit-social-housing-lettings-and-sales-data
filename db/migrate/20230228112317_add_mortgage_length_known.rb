class AddMortgageLengthKnown < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :mortlen_known, :integer
  end
end
