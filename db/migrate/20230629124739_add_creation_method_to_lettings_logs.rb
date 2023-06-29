class AddCreationMethodToLettingsLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :creation_method, :integer, default: 1
  end
end
