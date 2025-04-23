module InvalidLogsHelper
  def count_and_display_invalid_logs(model, log_type, year)
    Rails.logger.info "Starting to count invalid #{log_type} for year #{year}..."
    invalid_ids = []
    total_logs_seen = 0

    model.filter_by_year(year).find_in_batches(batch_size: 1000).with_index(1) do |batch, batch_index|
      Rails.logger.info "Processing batch #{batch_index} with #{batch.size} logs..."
      batch.each do |log|
        total_logs_seen += 1
        invalid_ids << log.id unless log.valid?
      end

      Rails.logger.info "Batch #{batch_index} complete. Progress: #{invalid_ids.size} invalid logs found out of #{total_logs_seen} logs seen so far."
    end

    Rails.logger.info "Counting complete for #{log_type}. Total invalid logs: #{invalid_ids.size}, Total logs seen: #{total_logs_seen}."
    Rails.logger.info "Invalid #{log_type} IDs: #{invalid_ids.join(', ')}" if invalid_ids.any?
    Rails.logger.info "--------------------------------"
  end

  def surface_invalid_logs(model, log_type, year)
    Rails.logger.info "Surfacing invalid #{log_type} for year #{year}..."
    invalid_ids = []
    total_logs_seen = 0

    model.filter_by_year(year).find_in_batches(batch_size: 1000).with_index(1) do |batch, batch_index|
      Rails.logger.info "Processing batch #{batch_index} with #{batch.size} logs..."
      batch.each do |log|
        total_logs_seen += 1
        next if log.valid?

        invalid_ids << log.id
        error_messages = log.errors.full_messages.join(";\n")
        Rails.logger.info "#{log_type} ID: #{log.id} \n Errors----\n #{error_messages}"
      end
      Rails.logger.info "Batch #{batch_index} complete. Processed #{batch.size} logs."
    end

    Rails.logger.info "Surfacing complete for #{log_type}. Total invalid logs: #{invalid_ids.size}, Total logs seen: #{total_logs_seen}."
    Rails.logger.info "Invalid #{log_type} IDs: #{invalid_ids.join(', ')}" if invalid_ids.any?
    Rails.logger.info "--------------------------------"
  end
end
