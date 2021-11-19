class ChangeRenewal < ActiveRecord::Migration[6.1]
  def change
    rename_column :case_logs, :tenant_same_property_renewal, :renewal
  end
end


