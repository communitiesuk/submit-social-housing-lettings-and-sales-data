desc "Alter age values from 0 to 1"
task correct_min_age_values: :environment do
  LettingsLog.where(age2: 0).update_all(age2: 1, values_updated_at: Time.zone.now)
  LettingsLog.where(age3: 0).update_all(age3: 1, values_updated_at: Time.zone.now)
  LettingsLog.where(age4: 0).update_all(age4: 1, values_updated_at: Time.zone.now)
  LettingsLog.where(age5: 0).update_all(age5: 1, values_updated_at: Time.zone.now)
  LettingsLog.where(age6: 0).update_all(age6: 1, values_updated_at: Time.zone.now)
  LettingsLog.where(age7: 0).update_all(age7: 1, values_updated_at: Time.zone.now)
  LettingsLog.where(age8: 0).update_all(age8: 1, values_updated_at: Time.zone.now)
end
