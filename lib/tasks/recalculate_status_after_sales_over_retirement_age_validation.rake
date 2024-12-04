desc "Recalculates status for 2024 logs that will trigger new sales over retirement age soft validation"
task recalculate_status_over_retirement: :environment do
  validation_trigger_condition = "(ecstat1 != 5 AND age1 > 66) OR (ecstat2 != 5 AND age2 > 66) OR (ecstat3 != 5 AND age3 > 66) OR (ecstat4 != 5 AND age4 > 66) OR (ecstat5 != 5 AND age5 > 66) OR (ecstat6 != 5 AND age6 > 66)"
  SalesLog.filter_by_year(2024).where(status: "pending", status_cache: "completed").where(validation_trigger_condition).find_each do |log|
    log.status_cache = log.calculate_status

    unless log.save
      Rails.logger.info "Could not save changes to pending sales log #{log.id}"
    end
  end

  SalesLog.filter_by_year(2024).where(status: "completed").where(validation_trigger_condition).find_each do |log|
    log.status = log.calculate_status

    unless log.save
      Rails.logger.info "Could not save changes to sales log #{log.id}"
    end
  end
end
