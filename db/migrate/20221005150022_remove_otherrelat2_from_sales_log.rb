class RemoveOtherrelat2FromSalesLog < ActiveRecord::Migration[7.0]
  def change
    remove_column :sales_logs, :otherrelat2, :string
  end
end
