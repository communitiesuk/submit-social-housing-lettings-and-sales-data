desc "Recalculates status for 2023 completed logs with missing LA"
task recalculate_status_missing_la: :environment do
  # See reinfer_local_authority - this covers cases where postcode_full was not set that should have been returned to in progress
  LettingsLog.filter_by_year(2023).where(needstype: 1, la: nil, status: "completed").find_each do |log|
    log.status = log.calculate_status

    unless log.save
      Rails.logger.info "Could not save changes to lettings log #{log.id}"
    end
  end

  SalesLog.filter_by_year(2023).where(la: nil, status: "completed").find_each do |log|
    log.status = log.calculate_status

    unless log.save
      Rails.logger.info "Could not save changes to sales log #{log.id}"
    end
  end
end

desc "Recalculates status for 2024 completed logs with missing LA"
task recalculate_status_missing_la_2024: :environment do
  LettingsLog.filter_by_year(2024).where(needstype: 1, la: nil, status: "completed").find_each do |log|
    log.status = log.calculate_status

    unless log.save
      Rails.logger.info "Could not save changes to lettings log #{log.id}"
    end
  end

  SalesLog.filter_by_year(2024).where(la: nil, status: "completed").find_each do |log|
    log.status = log.calculate_status

    unless log.save
      Rails.logger.info "Could not save changes to sales log #{log.id}"
    end
  end
end
