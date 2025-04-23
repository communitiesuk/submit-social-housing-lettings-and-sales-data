module InvalidLogsHelper
  def count_and_display_invalid_logs(model, log_type, year)
    invalid_ids = []
    total_logs_seen = 0

    model.filter_by_year(year).find_in_batches(batch_size: 1000) do |batch|
      batch.each do |log|
        total_logs_seen += 1
        invalid_ids << log.id unless log.valid?
      end

      Rails.logger.debug "Progress: #{invalid_ids.size} invalid logs found out of #{total_logs_seen} logs seen so far."
    end

    Rails.logger.info "Number of invalid #{log_type} for year #{year}: #{invalid_ids.size}"
    Rails.logger.info "Invalid #{log_type} IDs: #{invalid_ids.join(', ')}"
  end

  def surface_invalid_logs(model, log_type, year)
    model.filter_by_year(year).find_in_batches(batch_size: 1000) do |batch|
      batch.each do |log|
        next if log.valid?

        error_messages = log.errors.full_messages.join(";\n")
        Rails.logger.info "#{log_type} ID: #{log.id} \n Errors----\n #{error_messages}"
      end
    end
  end
end
