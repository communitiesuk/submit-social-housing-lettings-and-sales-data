class AddAbsorbingOrganisationIdToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_reference :organisations, :absorbing_organisation, null: true, foreign_key: { to_table: :organisations }
  end
end
