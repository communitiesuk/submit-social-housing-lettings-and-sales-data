class RemoveUserTypeFromCsvVariableDefinitions < ActiveRecord::Migration[7.0]
  def change
    remove_column :csv_variable_definitions, :user_type, :string
  end
end
