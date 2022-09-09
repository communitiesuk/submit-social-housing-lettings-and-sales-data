class CorrectReferralValue < ActiveRecord::Migration[7.0]
  def change
    LettingsLog.where(referral: 0).update_all(referral: 1)
  end
end
