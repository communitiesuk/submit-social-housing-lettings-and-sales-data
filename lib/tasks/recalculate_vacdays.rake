desc "Recalculate vacdays after bugfix for daylight savings time changes"
task recalculate_vacdays: :environment do
  LettingsLog.where.not(vacdays: nil).find_each do |log|
    Rails.logger.log("Log #{log.id}")
    recalculated_vacdays = log.send(:property_vacant_days)
    next if recalculated_vacdays == log.vacdays

    log.vacdays = recalculated_vacdays
    next if log.save

    Rails.logger.log("Log #{log.id} could not be saved, saving updated vacdays without validation")
    log.reload
    log.vacdays = recalculated_vacdays
    log.save!(validate: false)
  end
end
