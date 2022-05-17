class AddConfirmableUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.column :confirmation_token, :string
      t.column :confirmed_at, :datetime
      t.column :confirmation_sent_at, :datetime
      t.string :unconfirmed_email
    end
    add_index :users, :confirmation_token, unique: true
  end
end
