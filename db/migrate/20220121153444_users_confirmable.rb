class UsersConfirmable < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable
    end
  end
end
