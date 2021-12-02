class ChangeUserRoleToEnum < ActiveRecord::Migration[6.1]
  def up
    change_table :users, bulk: true do |t|
      t.remove :role
      t.column :role, :integer
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.remove :role
      t.column :role, :string
    end
  end
end
