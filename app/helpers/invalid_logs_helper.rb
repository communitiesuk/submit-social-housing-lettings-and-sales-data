module InvalidLogsHelper
  def count_and_display_invalid_logs(model, log_type, year)
    invalid_logs = fetch_invalid_logs(model, year)
    Rails.logger.info "Number of invalid #{log_type} for year #{year}: #{invalid_logs.size}"
    Rails.logger.info "Invalid #{log_type} IDs: #{invalid_logs.map(&:id).join(', ')}"
  end

  def surface_invalid_logs(model, log_type, year)
    invalid_logs = fetch_invalid_logs(model, year)
    if invalid_logs.any?
      invalid_logs.each do |log|
        Rails.logger.info "#{log_type} ID: #{log.id}"
        log.errors.full_messages.each { |message| Rails.logger.info "  - #{message}" }
      end
    else
      Rails.logger.info "No invalid #{log_type} found for year #{year}."
    end
  end

  def fetch_invalid_logs(model, year)
    model.filter_by_year(year).reject(&:valid?)
  end
end
