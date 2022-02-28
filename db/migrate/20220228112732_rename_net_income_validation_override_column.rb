class RenameNetIncomeValidationOverrideColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :case_logs, :override_net_income_validation, :net_income_value_check
  end
end
