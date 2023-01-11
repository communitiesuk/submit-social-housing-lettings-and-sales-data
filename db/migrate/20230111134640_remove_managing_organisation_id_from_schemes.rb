class RemoveManagingOrganisationIdFromSchemes < ActiveRecord::Migration[7.0]
  def up
    change_table :schemes, bulk: true do |t|
      t.remove :managing_organisation_id
    end
  end

  def down
    add_reference :schemes, :managing_organisation_id, foreign_key: { to_table: :organisations }
  end
end
