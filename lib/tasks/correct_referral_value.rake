desc "Alter referral values for lettings logs in the database to 1 if they are 0"
task correct_referral_value: :environment do
  LettingsLog.where(referral: 0).update_all(referral: 1)
end
