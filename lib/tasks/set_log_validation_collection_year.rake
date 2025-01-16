desc "Sets value for collection_year log validations depending on the from value"
task set_log_validation_collection_year: :environment do
  LogValidation.all.each do |log_validation|
    log_validation.update(collection_year: "#{log_validation.from.year}/#{log_validation.from.year + 1}")
  end
end
