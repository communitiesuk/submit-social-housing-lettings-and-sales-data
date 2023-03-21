class AddStudentNotChildValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :student_not_child_value_check, :integer
  end
end
