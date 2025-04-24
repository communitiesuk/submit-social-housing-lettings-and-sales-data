module InvalidLogsHelper
  def count_and_display_invalid_logs(model, log_type, year)
    Rails.logger.info "Starting to count invalid #{log_type} for year #{year}..."
    invalid_ids = []
    total_logs_checked = 0

    model.filter_by_year(year).where(status: "completed").find_in_batches(batch_size: 1000).with_index(1) do |batch, batch_index|
      Rails.logger.info "Processing batch #{batch_index} with #{batch.size} logs..."
      batch.each do |log|
        total_logs_checked += 1

        next unless log_invalid?(log)

        invalid_ids << log.id
      end

      Rails.logger.info "Batch #{batch_index} complete. Progress: #{invalid_ids.size} invalid logs found out of #{total_logs_checked} completed logs checked so far."
    end

    Rails.logger.info "Counting complete for #{log_type}. Total invalid logs: #{invalid_ids.size}, Total completed logs checked: #{total_logs_checked}."
    Rails.logger.info "Invalid #{log_type} IDs: #{invalid_ids.join(', ')}" if invalid_ids.any?
    Rails.logger.info "--------------------------------"
  end

  def surface_invalid_logs(model, log_type, year)
    Rails.logger.info "Surfacing invalid #{log_type} for year #{year}..."
    invalid_ids = []
    total_logs_checked = 0
    log_messages = []

    log_messages << headers(log_type).join(", ")

    model.filter_by_year(year).where(status: "completed").find_in_batches(batch_size: 1000).with_index(1) do |batch, batch_index|
      Rails.logger.info "Processing batch #{batch_index} with #{batch.size} logs..."
      batch.each do |log|
        total_logs_checked += 1

        next unless log_invalid?(log)

        invalid_ids << log.id
        log_row_data = log_row(log, log_type).join(", ")
        log_messages << log_row_data
        Rails.logger.info log_row_data
      end
      Rails.logger.info "Batch #{batch_index} complete. Processed #{batch.size} logs."
    end

    Rails.logger.info "Surfacing complete for #{log_type}. Total invalid logs: #{invalid_ids.size}, Total completed logs checked: #{total_logs_checked}."
    Rails.logger.info "Invalid #{log_type} IDs: #{invalid_ids.join(', ')}" if invalid_ids.any?
    Rails.logger.info log_messages.join("\n")
    Rails.logger.info "--------------------------------"
  end

  private

  def log_invalid?(log)
    !log.valid? || log.incomplete_subsections.any? || log.incomplete_questions.any?
  end

  def log_row(log, log_type)
    incomplete_subsections = log.incomplete_subsections.map(&:label).join("; ")
    incomplete_question_ids = log.incomplete_questions.map(&:id).join("; ")

    created_at = log.created_at&.strftime("%d/%m/%Y")
    updated_at = log.updated_at&.strftime("%d/%m/%Y")

    if log_type == "LettingsLog"
      [
        log.id,
        log.tenancycode,
        log.propcode,
        log.managing_organisation_id,
        log.managing_organisation&.name,
        log.assigned_to&.email,
        log.address_line1,
        log.address_line2,
        log.town_or_city,
        log.county,
        log.postcode_full,
        incomplete_subsections,
        incomplete_question_ids,
        log.status,
        created_at,
        updated_at,
      ]
    else
      [
        log.id,
        log.purchid,
        log.managing_organisation_id,
        log.managing_organisation&.name,
        log.assigned_to&.email,
        log.address_line1,
        log.address_line2,
        log.town_or_city,
        log.county,
        log.postcode_full,
        incomplete_subsections,
        incomplete_question_ids,
        log.status,
        created_at,
        updated_at,
      ]
    end
  end

  def headers(log_type)
    if log_type == "LettingsLog"
      [
        "Log ID",
        "Tenant Code",
        "Property Reference",
        "Managing Organisation ID",
        "Managing Organisation Name",
        "Assigned To (User Email)",
        "Address Line 1",
        "Address Line 2",
        "Town/City",
        "County",
        "Postcode",
        "Incomplete Subsections",
        "Incomplete Question IDs",
        "Status",
        "Created At",
        "Updated At",
      ]
    else
      [
        "Log ID",
        "Purchaser Code",
        "Managing Organisation ID",
        "Managing Organisation Name",
        "Assigned To (User Email)",
        "Address Line 1",
        "Address Line 2",
        "Town/City",
        "County",
        "Postcode",
        "Incomplete Subsections",
        "Incomplete Question IDs",
        "Status",
        "Created At",
        "Updated At",
      ]
    end
  end
end
