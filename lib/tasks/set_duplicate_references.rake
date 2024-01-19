desc "Set duplicate references for sales and lettings logs"
task set_duplicate_references: :environment do
  SalesLog.filter_by_year(2023).duplicate_sets.each do |duplicate_set|
    duplicate_set_id = generate_new_duplicate_set_id
    next if duplicate_set.any? { |_log_id| SalesLog.exists?(duplicate_set_id:) }

    duplicate_set.each do |log_id|
      log = SalesLog.find(log_id)
      log.duplicate_set_id = duplicate_set_id
      log.save!(touch: false, validate: false)
    end
  end

  LettingsLog.filter_by_year(2023).duplicate_sets.each do |duplicate_set|
    duplicate_set_id = generate_new_duplicate_set_id
    next if duplicate_set.any? { |_log_id| LettingsLog.exists?(duplicate_set_id:) }

    duplicate_set.each do |log_id|
      log = LettingsLog.find(log_id)
      log.duplicate_set_id = duplicate_set_id
      log.save!(touch: false, validate: false)
    end
  end
end

def generate_new_duplicate_set_id
  loop do
    duplicate_set_id = SecureRandom.random_number(1_000_000)
    return duplicate_set_id unless LettingsLog.exists?(duplicate_set_id:)
  end
end
