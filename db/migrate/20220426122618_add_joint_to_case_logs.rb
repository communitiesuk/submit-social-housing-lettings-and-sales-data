class AddJointToCaseLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :joint, :integer
  end
end
