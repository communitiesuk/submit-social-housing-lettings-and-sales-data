namespace :bulk_update do
  desc "Update nocharge with household_charge for current logs"
  task update_current_logs_nocharges: :environment do
    updated_logs_count = 0
    status_changed_logs = []

    logs = LettingsLog.where(startdate: Time.zone.local(2024, 4, 1)...Time.zone.local(2026, 4, 1)).where.not("nocharge = household_charge")
    puts "Updating logs with startdate between 2024-04-01 and 2026-04-01"
    puts "Total logs to update: #{logs.count}"

    logs.find_each do |log|
      status_pre_change = log.status

      log.nocharge = log.household_charge
      if log.save
        updated_logs_count += 1
        Rails.logger.info "Updated nocharge for log #{log.id}"
      else
        Rails.logger.error "Failed to update log #{log.id}: #{log.errors.full_messages.join(', ')}"
      end

      status_post_change = log.status
      status_changed_logs << log.id if status_pre_change != status_post_change
    end

    puts "#{updated_logs_count} logs were updated."
    puts "Logs with changed status: [#{status_changed_logs.join(', ')}]"
  end

  desc "Update nocharge with household_charge for older logs"
  task update_older_logs_nocharges: :environment do
    updated_logs_count = 0
    status_changed_logs = []

    logs = LettingsLog.where("startdate < ?", Time.zone.local(2024, 4, 1)).where.not("nocharge = household_charge")

    logs.find_each do |log|
      status_pre_change = log.status

      log.skip_update_status = true
      log.nocharge = log.household_charge
      if log.save
        updated_logs_count += 1
        Rails.logger.info "Updated nocharge for log #{log.id}"
      else
        Rails.logger.error "Failed to update log #{log.id}: #{log.errors.full_messages.join(', ')}"
      end

      status_post_change = log.status
      status_changed_logs << log.id if status_pre_change != status_post_change
    end

    puts "#{updated_logs_count} logs were updated."
    puts "Logs with changed status: [#{status_changed_logs.join(', ')}]"
  end
end
