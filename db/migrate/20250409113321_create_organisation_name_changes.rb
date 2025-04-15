class CreateOrganisationNameChanges < ActiveRecord::Migration[7.2]
  def change
    create_table :organisation_name_changes do |t|
      t.references :organisation, null: false, foreign_key: true
      t.string :name, null: false
      t.string :change_type
      t.datetime :change_date, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :organisation_name_changes, %i[organisation_id change_date], unique: true, name: "index_org_name_changes_on_org_id_and_change_date"
  end
end
