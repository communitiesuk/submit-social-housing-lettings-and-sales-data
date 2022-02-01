class RenameCaseLogFields < ActiveRecord::Migration[7.0]
  def change
    rename_column :case_logs, :tenant_same_property_renewal, :renewal
  end
end
