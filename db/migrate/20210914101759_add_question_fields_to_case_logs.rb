class AddQuestionFieldsToCaseLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :case_logs, :tenant_code, :string
    add_column :case_logs, :tenant_age, :integer
    add_column :case_logs, :tenant_gender, :string
    add_column :case_logs, :tenant_ethnic_group, :string 
    add_column :case_logs, :tenant_nationality, :string
    add_column :case_logs, :previous_housing_situation, :string
    add_column :case_logs, :prior_homelessness, :integer
    add_column :case_logs, :armed_forces, :string
  end
end
