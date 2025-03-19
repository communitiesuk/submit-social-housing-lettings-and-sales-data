namespace :bulk_update do
  desc "Update logs with specific criteria and set manual_address_entry_selected to true"
  task update_manual_address_entry_selected: :environment do
    updated_lettings_logs_count = 0
    updated_sales_logs_count = 0
    lettings_logs = LettingsLog.filter_by_year(2024)
                               .where(status: %w[in_progress completed])
                               .where(needstype: 1, manual_address_entry_selected: false, uprn: nil)

    lettings_logs.find_each do |log|
      next unless log.address_line1 || log.address_line2 || log.county || log.town_or_city || log.postcode_full

      status_pre_change = log.status
      log.manual_address_entry_selected = true
      if log.save
        updated_lettings_logs_count += 1
      else
        Rails.logger.info "Could not save changes to lettings log #{log.id}"
      end
      status_post_change = log.status
      unless status_pre_change == status_post_change
        Rails.logger.info "Status changed from #{status_pre_change} to #{status_post_change} for lettings log #{log.id}"
      end
    end

    puts "#{updated_lettings_logs_count} lettings logs updated."

    sales_logs = SalesLog.filter_by_year(2024)
                         .where(status: %w[in_progress completed])
                         .where(manual_address_entry_selected: false, uprn: nil)

    sales_logs.find_each do |log|
      next unless log.address_line1 || log.address_line2 || log.county || log.town_or_city || log.postcode_full

      status_pre_change = log.status
      log.manual_address_entry_selected = true
      if log.save
        updated_sales_logs_count += 1
      else
        Rails.logger.info "Could not save changes to sales log #{log.id}"
      end
      status_post_change = log.status
      unless status_pre_change == status_post_change
        Rails.logger.info "Status changed from #{status_pre_change} to #{status_post_change} for sales log #{log.id}"
      end
    end

    puts "#{updated_sales_logs_count} sales logs updated."
  end
end
