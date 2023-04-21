class AddMergeOrganisations < ActiveRecord::Migration[7.0]
  def change
    create_table :merge_request_organisations do |t|
      t.integer :merge_request_id, foreign_key: true
      t.integer :merging_organisation_id, foreign_key: true
      t.timestamps
    end
  end
end
