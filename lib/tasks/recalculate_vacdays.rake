desc "Recalculate vacdays after bugfix for daylight savings time changes"
task recalculate_vacdays: :environment do
  logs = LettingsLog.where.not(vacdays: nil)
  logs.each do |log|
    recalculated_vacdays = log.send(:property_vacant_days)
    next if recalculated_vacdays == log.vacdays

    log.vacdays = recalculated_vacdays
    log.save!(validate: false)
  end
end
