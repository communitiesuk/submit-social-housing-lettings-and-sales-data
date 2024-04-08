desc "Updates created_by values for lettings and sales logs"
task update_created_by_values: :environment do
  LettingsLog.filter_by_years(%w[2023 2024]).where.not(bulk_upload_id: nil).update_all("created_by_id = (SELECT user_id FROM bulk_uploads WHERE bulk_uploads.id = lettings_logs.bulk_upload_id)")
  LettingsLog.filter_by_years(%w[2023 2024]).where(bulk_upload_id: nil).each do |lettings_log|
    whodunnit = PaperTrail::Version.find_by(item_id: lettings_log.id, event: "create")&.whodunnit
    next if whodunnit.blank?

    user = GlobalID::Locator.locate whodunnit
    next if user.blank?

    lettings_log.created_by = user
    lettings_log.save!(touch: false, validate: false)
  end

  SalesLog.filter_by_years(%w[2023 2024]).where.not(bulk_upload_id: nil).update_all("created_by_id = (SELECT user_id FROM bulk_uploads WHERE bulk_uploads.id = sales_logs.bulk_upload_id)")
  SalesLog.filter_by_years(%w[2023 2024]).where(bulk_upload_id: nil).each do |sales_log|
    whodunnit = PaperTrail::Version.find_by(item_id: sales_log.id, event: "create")&.whodunnit
    next if whodunnit.blank?

    user = GlobalID::Locator.locate whodunnit
    next if user.blank?

    sales_log.created_by = user
    sales_log.save!(touch: false, validate: false)
  end
end
