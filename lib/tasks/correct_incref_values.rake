desc "Alter incref values for non imported lettings logs in the database"
task correct_incref_values: :environment do
  LettingsLog.where(old_id: nil, net_income_known: 0).update!(incref: 0)
  LettingsLog.where(old_id: nil, net_income_known: 1).update!(incref: 2)
  LettingsLog.where(old_id: nil, net_income_known: 2).update!(incref: 1)
end
