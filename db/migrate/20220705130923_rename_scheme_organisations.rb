class RenameSchemeOrganisations < ActiveRecord::Migration[7.0]
  def change
    change_table :schemes, bulk: true do |t|
      t.rename :organisation_id, :owning_organisation_id
      t.rename :stock_owning_organisation_id, :managing_organisation_id
    end
  end
end
