desc "Recalculate vacdays after bugfix for daylight savings time changes"
task recalculate_vacdays: :environment do
  logs = LettingsLog.filter_by_years(%w[2023 2024]).where.not(vacdays: nil)
  logs.each(&:save!)
end
