class AddNationalColumn < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :national, :integer
      t.column :othernational, :string
    end
  end
end
