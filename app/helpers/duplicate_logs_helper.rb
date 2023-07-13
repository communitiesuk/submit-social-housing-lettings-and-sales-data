module DuplicateLogsHelper
  include GovukLinkHelper

  def duplicate_logs_continue_button(all_duplicates, duplicate_log, original_log)
    if all_duplicates.count > 1
      return govuk_button_link_to "Keep this log and delete duplicates", url_for(
        controller: "duplicate_logs",
        action: "delete_duplicates",
        "#{duplicate_log.class.name.underscore}_id": duplicate_log.id,
        original_log_id: original_log.id,
      )
    end

    if !original_log.deleted?
      govuk_button_link_to "Back to Log #{original_log.id}", send("#{original_log.class.name.underscore}_path", original_log)
    else
      type = duplicate_log.lettings? ? "lettings" : "sales"
      govuk_button_link_to "Back to #{type} logs", url_for(duplicate_log.class)
    end
  end

  def duplicate_logs_action_href(log, page_id, original_log_id)
    send("#{log.model_name.param_key}_#{page_id}_path", log, referrer: "interruption_screen", original_log_id:)
  end

  def change_duplicate_logs_action_href(log, page_id, all_duplicates, original_log_id)
    first_remaining_duplicate_id = all_duplicates.map(&:id).reject { |id| id == log.id }.first
    send("#{log.model_name.param_key}_#{page_id}_path", log, referrer: "duplicate_logs", first_remaining_duplicate_id:, original_log_id:)
  end
  
  def duplicates_for_user(user)
    duplicate_sets = { lettings: {}, sales: {} }
    lettings_count = 0
    sales_count = 0
    duplicate_lettings_ids = Set.new
    duplicate_sales_ids = Set.new

    user.lettings_logs(created_by: true).each do |log|
      next if duplicate_lettings_ids.include? log.id

      duplicates = LettingsLog.filter_by_organisation(user.organisation).duplicate_logs(log)
      if duplicates.any?
        duplicate_ids = [log.id, *duplicates.map(&:id)]
        duplicate_sets[:lettings][lettings_count] = duplicate_ids
        lettings_count += 1
        duplicate_lettings_ids << duplicate_ids
      end
    end

    user.sales_logs(created_by: true).each do |log|
      next if duplicate_sales_ids.include? log.id

      duplicates = SalesLog.filter_by_organisation(user.organisation).duplicate_logs(log)
      if duplicates.any?
        duplicate_ids = [log.id, *duplicates.map(&:id)]
        duplicate_sets[:sales][sales_count] = duplicate_ids
        sales_count += 1
        duplicate_sales_ids << duplicate_ids
      end
    end

    return if duplicate_lettings_ids.empty? && duplicate_sales_ids.empty?

    duplicate_sets
  end
end
