desc "Set duplicate references for sales and lettings logs"
task set_duplicate_references: :environment do
  SalesLog.filter_by_year(2023).duplicate_sets.each do |duplicate_set|
    duplicate_set_id = generate_new_duplicate_set_id
    next if duplicate_set.any? { |log_id| DuplicateLogReference.exists?(log_id:, log_type: "SalesLog") }

    duplicate_set.each do |log_id|
      DuplicateLogReference.create(log_id:, log_type: "SalesLog", duplicate_set_id:)
    end
  end

  LettingsLog.filter_by_year(2023).duplicate_sets.each do |duplicate_set|
    duplicate_set_id = generate_new_duplicate_set_id
    next if duplicate_set.any? { |log_id| DuplicateLogReference.exists?(log_id:, log_type: "LettingsLog") }

    duplicate_set.each do |log_id|
      DuplicateLogReference.create(log_id:, log_type: "LettingsLog", duplicate_set_id:)
    end
  end
end

def generate_new_duplicate_set_id
  loop do
    duplicate_set_id = SecureRandom.random_number(1_000_000)
    return duplicate_set_id unless DuplicateLogReference.exists?(duplicate_set_id:)
  end
end
