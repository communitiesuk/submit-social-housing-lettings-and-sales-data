desc "Alter incref values for non imported lettings logs in the database"
task correct_incref_values: :environment do
  LettingsLog.where(old_id: nil, net_income_known: 0).update_all(incref: 0, updated_at: Time.zone.now)
  LettingsLog.where(old_id: nil, net_income_known: 1).update_all(incref: 2, updated_at: Time.zone.now)
  LettingsLog.where(old_id: nil, net_income_known: 2).update_all(incref: 1, updated_at: Time.zone.now)
end
