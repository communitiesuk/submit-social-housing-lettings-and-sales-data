class AddNameEmailRoleOrgToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :string
    add_column :users, :organisation, :string
  end
end
