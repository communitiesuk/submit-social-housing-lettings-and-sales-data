class AddReferralValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :referral_value_check, :integer
  end
end
