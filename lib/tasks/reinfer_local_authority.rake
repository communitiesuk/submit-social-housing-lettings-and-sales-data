desc "Reinfers LA from postcode where it's missing"
task reinfer_local_authority: :environment do
  LettingsLog.filter_by_year(2023).where(needstype: 1, la: nil).where.not(postcode_full: nil).find_each do |log|
    log.process_postcode_changes!

    Rails.logger.info "Invalid lettings log: #{log.id}" unless log.save
  end

  SalesLog.filter_by_year(2023).where(la: nil).where.not(postcode_full: nil).find_each do |log|
    log.process_postcode_changes!

    Rails.logger.info "Invalid sales log: #{log.id}" unless log.save
  end
end
