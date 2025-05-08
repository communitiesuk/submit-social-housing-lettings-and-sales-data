class AddSelectedOrganisationToSalesLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :sales_logs, :has_selected_organisation, :boolean, default: true
  end
end
