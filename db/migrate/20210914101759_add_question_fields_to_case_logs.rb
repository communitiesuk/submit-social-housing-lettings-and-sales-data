class AddQuestionFieldsToCaseLogs < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :tenant_code, :string
      t.column :tenant_age, :integer
      t.column :tenant_gender, :string
      t.column :tenant_ethnic_group, :string
      t.column :tenant_nationality, :string
      t.column :previous_housing_situation, :string
      t.column :prior_homelessness, :integer
      t.column :armed_forces, :string
    end
  end
end
