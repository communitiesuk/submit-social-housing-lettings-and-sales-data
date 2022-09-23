class CreateLegacyUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :legacy_users do |t|
      t.string :old_user_id
      t.integer :user_id

      t.timestamps
    end

    add_index :legacy_users, :old_user_id, unique: true
  end
end
