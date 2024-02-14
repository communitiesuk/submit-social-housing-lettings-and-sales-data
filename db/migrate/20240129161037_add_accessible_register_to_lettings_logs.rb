class AddAccessibleRegisterToLettingsLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :accessible_register, :integer
  end
end
