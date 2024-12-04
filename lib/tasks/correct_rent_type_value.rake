desc "Alter rent_type values for bulk uploaded lettings logs for 2024 where they were not mapped correctly"
task correct_rent_type_value: :environment do
  affected_uploads = BulkUpload.where(log_type: "lettings", year: 2024, rent_type_fix_status: BulkUpload.rent_type_fix_statuses[:not_applied])
  affected_uploads.each do |upload|
    upload.logs.where.not(rent_type: nil).each do |log|
      current_rent_type = log.rent_type
      rent_type_at_upload = log.versions.length == 1 ? log.rent_type : log.versions.first.next.reify.rent_type
      next unless rent_type_at_upload == current_rent_type

      new_rent_type_value = BulkUpload::Lettings::Year2024::RowParser::RENT_TYPE_BU_MAPPING[rent_type_at_upload]
      log.rent_type = new_rent_type_value
      if log.save
        Rails.logger.info("Log #{log.id} rent_type updated from #{rent_type_at_upload} to #{log.rent_type}")
      else
        Rails.logger.error("Log #{log.id} rent_type could not be updated from #{rent_type_at_upload} to #{log.rent_type}. Error: #{log.errors.full_messages.join(', ')}")
      end
    end
    upload.update!(rent_type_fix_status: BulkUpload.rent_type_fix_statuses[:applied])
  end
end
