desc "Clear earnings for lettings logs that fail validation"
task clear_invalidated_earnings: :environment do
  LettingsLog.filter_by_year(2023).find_each do |lettings_log|
    lettings_log.validate_net_income(lettings_log)
    if lettings_log.errors[:earnings].present?
      lettings_log.earnings = nil
      lettings_log.incfreq = nil
      lettings_log.save!(validate: false)
    end
  end
  LettingsLog.filter_by_year(2022).find_each do |lettings_log|
    lettings_log.validate_net_income(lettings_log)
    if lettings_log.errors[:earnings].present?
      lettings_log.earnings = nil
      lettings_log.incfreq = nil
      lettings_log.save!(validate: false, touch: false)
    end
  end
end
