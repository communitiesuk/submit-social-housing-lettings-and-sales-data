desc "Set lettings renttype_detail depending on rent_type"
task set_renttype_detail: :environment do
  LettingsLog.where(rent_type: 0).update_all(renttype_detail: 1)
  LettingsLog.where(rent_type: 1).update_all(renttype_detail: 2)
  LettingsLog.where(rent_type: 2).update_all(renttype_detail: 3)
  LettingsLog.where(rent_type: 3).update_all(renttype_detail: 4)
  LettingsLog.where(rent_type: 4).update_all(renttype_detail: 5)
  LettingsLog.where(rent_type: 5).update_all(renttype_detail: 6)
end
