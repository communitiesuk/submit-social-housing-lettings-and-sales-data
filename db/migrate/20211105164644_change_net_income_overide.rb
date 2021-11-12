class ChangeNetIncomeOveride < ActiveRecord::Migration[6.1]
  def up
    change_column :case_logs, :override_net_income_validation, "integer USING CAST(override_net_income_validation AS integer)"
  end

  def down
    change_column :case_logs, :override_net_income_validation, "boolean USING override_net_income_validation::boolean"
  end
end
