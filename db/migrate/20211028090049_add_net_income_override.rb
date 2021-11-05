class AddNetIncomeOverride < ActiveRecord::Migration[6.1]
  def change
    add_column :case_logs, :override_net_income_validation, :boolean
  end
end
