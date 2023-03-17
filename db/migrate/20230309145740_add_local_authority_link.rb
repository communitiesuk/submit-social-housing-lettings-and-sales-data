class AddLocalAuthorityLink < ActiveRecord::Migration[7.0]
  def change
    create_table :local_authority_links do |t|
      t.references :local_authority
      t.references :linked_local_authority

      t.timestamps
    end
    add_foreign_key :local_authority_links, :local_authorities, column: :local_authority_id
    add_foreign_key :local_authority_links, :local_authorities, column: :linked_local_authority_id
  end
end
