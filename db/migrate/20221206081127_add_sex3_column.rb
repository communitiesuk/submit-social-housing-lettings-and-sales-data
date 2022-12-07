class AddSex3Column < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :sex3, :string
  end
end
