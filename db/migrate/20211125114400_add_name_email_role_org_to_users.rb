class AddNameEmailRoleOrgToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.column :name, :string
      t.column :role, :string
      t.column :organisation, :string
    end
  end
end
