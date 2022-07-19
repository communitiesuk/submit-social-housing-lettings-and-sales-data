class AddStockOwningOrganisationToSchemes < ActiveRecord::Migration[7.0]
  def change
    add_reference :schemes, :stock_owning_organisation, foreign_key: { to_table: :organisations }, column: "owning_organisation_id"
  end
end
