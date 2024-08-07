desc "Updates created_by values for lettings and sales logs"
task update_created_by_values: :environment do
  LettingsLog.filter_by_years(%w[2023 2024]).where.not(bulk_upload_id: nil).update_all("created_by_id = (SELECT user_id FROM bulk_uploads WHERE bulk_uploads.id = lettings_logs.bulk_upload_id)")
  LettingsLog.filter_by_years(%w[2023 2024]).where(bulk_upload_id: nil, created_by: nil).find_each do |lettings_log|
    user = PaperTrail::Version.find_by(item_id: lettings_log.id, item_type: "LettingsLog", event: "create")&.actor
    lettings_log.created_by = if user.present? && user.is_a?(User)
                                user
                              else
                                lettings_log.assigned_to
                              end
    lettings_log.save!(touch: false, validate: false)
  end

  SalesLog.filter_by_years(%w[2023 2024]).where.not(bulk_upload_id: nil).update_all("created_by_id = (SELECT user_id FROM bulk_uploads WHERE bulk_uploads.id = sales_logs.bulk_upload_id)")
  SalesLog.filter_by_years(%w[2023 2024]).where(bulk_upload_id: nil, created_by: nil).find_each do |sales_log|
    user = PaperTrail::Version.find_by(item_id: sales_log.id, item_type: "SalesLog", event: "create")&.actor
    sales_log.created_by = if user.present? && user.is_a?(User)
                             user
                           else
                             sales_log.assigned_to
                           end
    sales_log.save!(touch: false, validate: false)
  end
end
