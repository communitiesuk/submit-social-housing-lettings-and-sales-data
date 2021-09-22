class RenameTenantFields < ActiveRecord::Migration[6.1]
  def change
    rename_column :case_logs, :economic_status, :tenant_economic_status
    rename_column :case_logs, :number_of_other_members, :household_number_of_other_members
  end
end
