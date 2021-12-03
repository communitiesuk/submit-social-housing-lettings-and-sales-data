class TwoFactorAuthenticationAddToAdminUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :admin_users, bulk: true do |t|
      t.column :second_factor_attempts_count, :integer, default: 0
      t.column :encrypted_otp_secret_key, :string
      t.column :encrypted_otp_secret_key_iv, :string
      t.column :encrypted_otp_secret_key_salt, :string
      t.column :direct_otp, :string
      t.column :direct_otp_sent_at, :datetime
      t.column :totp_timestamp, :timestamp
      t.column :phone, :string

      t.index :encrypted_otp_secret_key, unique: true
    end
  end
end
