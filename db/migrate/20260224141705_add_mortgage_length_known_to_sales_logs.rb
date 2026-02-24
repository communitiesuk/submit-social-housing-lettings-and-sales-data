class AddMortgageLengthKnownToSalesLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :sales_logs, :mortgage_length_known, :integer
  end
end
