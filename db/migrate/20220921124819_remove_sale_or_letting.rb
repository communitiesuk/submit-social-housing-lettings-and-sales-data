class RemoveSaleOrLetting < ActiveRecord::Migration[7.0]
  def change
    remove_column :lettings_logs, :sale_or_letting, :string
  end
end
