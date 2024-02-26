desc "Alter noint values for bulk uploaded sales logs where these have not been set in the service"
task correct_noint_value: :environment do
  update_counts = {
    in_progress: 0,
    completed: 0,
    pending: 0,
    deleted: 0,
  }
  affected_uploads = BulkUpload.where(log_type: "sales", noint_fix_status: BulkUpload.noint_fix_statuses[:not_applied])
  affected_uploads.each do |upload|
    upload.logs.where(noint: 2).each do |log|
      noint_at_upload = log.versions.length == 1 ? log.noint : log.versions.first.next.reify.noint
      next unless noint_at_upload == 2

      Rails.logger.info("Updating noint value on log #{log.id}, owning org #{log.owning_organisation_id}")
      update_counts[log.status.to_sym] += 1
      log.noint = 1
      log.skip_update_status = true
      log.save!
    end
    upload.update!(noint_fix_status: BulkUpload.noint_fix_statuses[:applied])
  end
  Rails.logger.info("Logs updated; #{update_counts}")
end
