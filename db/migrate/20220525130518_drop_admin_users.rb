class DropAdminUsers < ActiveRecord::Migration[7.0]
  def up
    drop_table :admin_users
  end

  def down
    create_table "admin_users", force: :cascade do |t|
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at", precision: nil
      t.datetime "remember_created_at", precision: nil
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "second_factor_attempts_count", default: 0
      t.string "encrypted_otp_secret_key"
      t.string "encrypted_otp_secret_key_iv"
      t.string "encrypted_otp_secret_key_salt"
      t.string "direct_otp"
      t.datetime "direct_otp_sent_at", precision: nil
      t.datetime "totp_timestamp", precision: nil
      t.string "phone"
      t.string "name"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at", precision: nil
      t.datetime "last_sign_in_at", precision: nil
      t.string "current_sign_in_ip"
      t.string "last_sign_in_ip"
      t.integer "failed_attempts", default: 0
      t.string "unlock_token"
      t.datetime "locked_at", precision: nil
      t.index %w[encrypted_otp_secret_key], name: "index_admin_users_on_encrypted_otp_secret_key", unique: true
      t.index %w[unlock_token], name: "index_admin_users_on_unlock_token", unique: true
    end
  end
end
