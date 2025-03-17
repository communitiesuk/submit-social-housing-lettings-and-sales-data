namespace :bulk_update do
  desc "Update logs with specific criteria and set manual_address_entry_selected to true"
  task update_manual_address_entry_selected: :environment do
    lettings_logs = LettingsLog.filter_by_year(2024)
                               .where(status: %w[in_progress completed])
                               .where(needstype: 1, manual_address_entry_selected: false, uprn: nil)

    lettings_logs.find_each do |log|
      log.update(manual_address_entry_selected: true)
    end

    puts "#{lettings_logs.count} lettings logs updated."

    sales_logs = SalesLog.filter_by_year(2024)
                         .where(status: %w[in_progress completed])
                         .where(manual_address_entry_selected: false, uprn: nil)

    sales_logs.find_each do |log|
      log.update(manual_address_entry_selected: true)
    end

    puts "#{sales_logs.count} sales logs updated."
  end
end
