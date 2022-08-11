class AddParentChildRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :organisation_relationships do |t|
      t.integer :child_organisation_id, foreign_key: true
      t.integer :parent_organisation_id, foreign_key: true
      t.timestamps
    end
  end
end
