namespace :bulk_update do
  desc "Update logs with specific criteria and set manual_address_entry_selected to true"
  task update_manual_address_entry_selected: :environment do
    updated_lettings_logs_count = 0
    lettings_status_changed_log_ids = []
    lettings_postcode_fixed_count = 0
    updated_sales_logs_count = 0
    sales_status_changed_log_ids = []
    sales_postcode_fixed_count = 0

    lettings_logs = LettingsLog.filter_by_year(2024)
                               .where(status: %w[in_progress completed])
                               .where(needstype: 1, manual_address_entry_selected: false, uprn: nil)
                               .where("(address_line1 IS NOT NULL AND address_line1 != '') OR (address_line2 IS NOT NULL AND address_line2 != '') OR (town_or_city IS NOT NULL AND town_or_city != '') OR (county IS NOT NULL AND county != '') OR (postcode_full IS NOT NULL AND postcode_full != '')")

    lettings_logs.find_each do |log|
      status_pre_change = log.status
      log.manual_address_entry_selected = true
      if log.save
        updated_lettings_logs_count += 1
      else
        Rails.logger.info "Could not save changes to lettings log #{log.id}"
      end
      status_post_change = log.status
      if status_pre_change != status_post_change
        if log.postcode_full.nil? && log.address_line1 == log.address_line1_input
          log.postcode_full = log.postcode_full_input
          log.save!
        end
        if log.status == status_pre_change
          lettings_postcode_fixed_count += 1
        else
          Rails.logger.info "Status changed from #{status_pre_change} to #{status_post_change} for lettings log #{log.id}"
          lettings_status_changed_log_ids << log.id
        end
      end
    end

    puts "#{updated_lettings_logs_count} lettings logs updated."
    puts "Lettings logs with status changes: [#{lettings_status_changed_log_ids.join(', ')}]"
    puts "Lettings logs where postcode fix maintained status: #{lettings_postcode_fixed_count}"

    sales_logs = SalesLog.filter_by_year(2024)
                         .where(status: %w[in_progress completed])
                         .where(manual_address_entry_selected: false, uprn: nil)
                         .where("(address_line1 IS NOT NULL AND address_line1 != '') OR (address_line2 IS NOT NULL AND address_line2 != '') OR (town_or_city IS NOT NULL AND town_or_city != '') OR (county IS NOT NULL AND county != '') OR (postcode_full IS NOT NULL AND postcode_full != '')")

    sales_logs.find_each do |log|
      status_pre_change = log.status
      log.manual_address_entry_selected = true
      if log.save
        updated_sales_logs_count += 1
      else
        Rails.logger.info "Could not save changes to sales log #{log.id}"
      end
      status_post_change = log.status
      if status_pre_change != status_post_change
        if log.postcode_full.nil? && log.address_line1 == log.address_line1_input
          log.postcode_full = log.postcode_full_input
          log.save!
        end
        if log.status == status_pre_change
          sales_postcode_fixed_count += 1
        else
          Rails.logger.info "Status changed from #{status_pre_change} to #{status_post_change} for sales log #{log.id}"
          sales_status_changed_log_ids << log.id
        end
      end
    end

    puts "#{updated_sales_logs_count} sales logs updated."
    puts "Sales logs with status changes: [#{sales_status_changed_log_ids.join(', ')}]"
    puts "Sales logs where postcode fix maintained status: #{sales_postcode_fixed_count}"
  end
end
