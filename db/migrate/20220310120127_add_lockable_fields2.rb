class AddLockableFields2 < ActiveRecord::Migration[7.0]
  def change
    change_table :admin_users, bulk: true do |t|
      t.column :failed_attempts, :integer, default: 0
      t.column :unlock_token, :string
      t.column :locked_at, :datetime
    end
    add_index :admin_users, :unlock_token, unique: true
  end
end
