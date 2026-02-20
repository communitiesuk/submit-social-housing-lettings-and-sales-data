class Add2026ReferralFields < ActiveRecord::Migration[7.2]
  def change
    change_table :lettings_logs, bulk: true do |t|
      t.integer :referral_register
      t.integer :referral_noms
      t.integer :referral_org
    end
  end
end
