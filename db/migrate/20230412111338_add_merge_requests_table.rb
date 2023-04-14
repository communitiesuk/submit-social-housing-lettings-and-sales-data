class AddMergeRequestsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :merge_requests do |t|
      t.integer :requesting_organisation_id
      t.text :other_merging_organisations
      t.timestamps
    end
  end
end
