class AddRentValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :rent_value_check, :integer
  end
end
