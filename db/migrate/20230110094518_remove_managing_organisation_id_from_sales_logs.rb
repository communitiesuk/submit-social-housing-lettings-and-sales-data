class RemoveManagingOrganisationIdFromSalesLogs < ActiveRecord::Migration[7.0]
  def up
    change_table :sales_logs, bulk: true do |t|
      t.remove :managing_organisation_id
    end
  end

  def down
    change_table :sales_logs, bulk: true do |t|
      t.column :managing_organisation_id, :bigint
    end
  end
end
