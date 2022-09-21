class AddOtherOutrightSaleField < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :othtype, :string
  end
end
