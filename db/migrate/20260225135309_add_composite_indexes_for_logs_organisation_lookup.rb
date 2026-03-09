class AddCompositeIndexesForLogsOrganisationLookup < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :lettings_logs, %i[owning_organisation_id id],
              order: { id: :desc },
              name: "index_lettings_logs_on_owning_org_and_id_desc",
              algorithm: :concurrently

    add_index :lettings_logs, %i[managing_organisation_id id],
              order: { id: :desc },
              name: "index_lettings_logs_on_managing_org_and_id_desc",
              algorithm: :concurrently

    add_index :sales_logs, %i[owning_organisation_id id],
              order: { id: :desc },
              name: "index_sales_logs_on_owning_org_and_id_desc",
              algorithm: :concurrently

    add_index :sales_logs, %i[managing_organisation_id id],
              order: { id: :desc },
              name: "index_sales_logs_on_managing_org_and_id_desc",
              algorithm: :concurrently
  end
end
