class RenameValidationsTable < ActiveRecord::Migration[7.0]
  def change
    rename_table :validations, :log_validations
  end
end
