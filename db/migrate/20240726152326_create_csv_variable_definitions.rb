class CreateCsvVariableDefinitions < ActiveRecord::Migration[7.0]
  def change
    create_table :csv_variable_definitions do |t|
      t.string :variable, null: false
      t.string :definition, null: false
      t.string :log_type, null: false
      t.integer :year, null: false
      t.datetime :last_accessed
      t.timestamps
    end

    add_check_constraint :csv_variable_definitions, "log_type IN ('lettings', 'sales')", name: "log_type_check"
    add_check_constraint :csv_variable_definitions, "year BETWEEN 2000 AND 2099", name: "year_check"
  end
end
