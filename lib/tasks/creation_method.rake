desc "set creation method to bulk upload if a log has a bulk upload id"
task set_creation_method: :environment do
  LettingsLog.where.not(bulk_upload_id: nil).update_all(creation_method: 2)
  SalesLog.where.not(bulk_upload_id: nil).update_all(creation_method: 2)
end
