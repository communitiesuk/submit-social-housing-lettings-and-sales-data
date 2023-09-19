desc "Alter ppcodenk values for non imported lettings logs in the database"
task correct_ppcodenk_values: :environment do
  LettingsLog.where.not(ppcodenk: nil).find_each do |log|
    log.update_columns(ppcodenk: log.ppcodenk == 1 ? 0 : 1)
  end
end
