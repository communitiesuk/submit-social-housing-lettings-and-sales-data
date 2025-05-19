class CreateOrganisationNameChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :organisation_name_changes do |t|
      t.references :organisation, null: false, foreign_key: true
      t.string :name, null: false
      t.date :startdate, null: false
      t.date :discarded_at

      t.timestamps
    end

    add_index :organisation_name_changes, %i[organisation_id startdate discarded_at], unique: true, name: "index_org_name_changes_on_org_id_startdate_discarded_at"
  end
end
