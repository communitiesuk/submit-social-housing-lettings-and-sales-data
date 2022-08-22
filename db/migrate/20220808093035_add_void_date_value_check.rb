class AddVoidDateValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :void_date_value_check, :integer
  end
end
