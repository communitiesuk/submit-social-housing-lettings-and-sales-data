class CreateOrganisations < ActiveRecord::Migration[6.1]
  def change
    create_table :organisations do |t|
      t.string :name
      t.integer :phone
      t.integer :org_type
      t.string :address_line1
      t.string :address_line2
      t.string :postcode
      t.string :local_authorities
      t.boolean :holds_own_stock
      t.string :other_stock_owners
      t.string :managing_agents

      t.timestamps
    end
  end
end
