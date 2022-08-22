class AddMajorRepairsDateValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :major_repairs_date_value_check, :integer
  end
end
