class AddRetirementValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :retirement_value_check, :integer
  end
end
