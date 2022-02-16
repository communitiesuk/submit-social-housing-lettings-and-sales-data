class AddTrackableToAdminUser < ActiveRecord::Migration[7.0]
  def change
    change_table :admin_users, bulk: true do |t|
      t.string :name
      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end
  end
end
