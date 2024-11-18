desc "clear benefit value for logs that would trigger the validation"
task clear_invalid_benefits: :environment do
  validation_trigger_condition = "ecstat1 = 1 OR ecstat1 = 2 OR (ecstat2 = 1 AND relat2 = 'P') OR (ecstat2 = 2 AND relat2 = 'P') OR (ecstat3 = 1 AND relat3 = 'P') OR (ecstat3 = 2 AND relat3 = 'P') OR (ecstat4 = 1 AND relat4 = 'P') OR (ecstat4 = 2 AND relat4 = 'P') OR (ecstat5 = 1 AND relat5 = 'P') OR (ecstat5 = 2 AND relat5 = 'P') OR (ecstat6 = 1 AND relat6 = 'P') OR (ecstat6 = 2 AND relat6 = 'P') OR (ecstat7 = 1 AND relat7 = 'P') OR (ecstat7 = 2 AND relat7 = 'P') OR (ecstat8 = 1 AND relat8 = 'P') OR (ecstat8 = 2 AND relat8 = 'P')"
  LettingsLog.filter_by_year(2024).where(status: "pending", status_cache: "completed", benefits: 1).where(validation_trigger_condition).find_each do |log|
    log.status_cache = log.calculate_status
    log.skip_update_status = true

    unless log.save
      Rails.logger.info "Could not save changes to pending lettings log #{log.id}"
    end
  end

  LettingsLog.filter_by_year(2024).visible.where(benefits: 1).where(validation_trigger_condition).find_each do |log|
    unless log.save
      Rails.logger.info "Could not save changes to lettings log #{log.id}"
    end
  end
end
