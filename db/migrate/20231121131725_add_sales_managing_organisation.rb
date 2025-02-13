class AddSalesManagingOrganisation < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.references :managing_organisation
    end
  end
end
