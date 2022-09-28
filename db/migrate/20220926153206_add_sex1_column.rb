class AddSex1Column < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :sex1, :string
  end
end
