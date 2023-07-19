module DuplicateLogsHelper
  include GovukLinkHelper

  def duplicate_logs_continue_button(all_duplicates, duplicate_log, original_log_id)
    if all_duplicates.count > 1
      return govuk_button_link_to "Keep this log and delete duplicates", url_for(
        controller: "duplicate_logs",
        action: "delete_duplicates",
        "#{duplicate_log.class.name.underscore}_id": duplicate_log.id,
        original_log_id:,
      )
    end

    if original_log_id == duplicate_log.id
      govuk_button_link_to "Back to Log #{duplicate_log.id}", send("#{duplicate_log.class.name.underscore}_path", duplicate_log)
    else
      type = duplicate_log.lettings? ? "lettings" : "sales"
      govuk_button_link_to "Back to #{type} logs", url_for(duplicate_log.class)
    end
  end

  def duplicate_logs_action_href(log, page_id, original_log_id)
    send("#{log.model_name.param_key}_#{page_id}_path", log, referrer: "interruption_screen", original_log_id:)
  end

  def change_duplicate_logs_action_href(log, page_id, all_duplicates)
    remaining_duplicate_id = all_duplicates.map(&:id).reject { |id| id == log.id }.first
    send("#{log.model_name.param_key}_#{page_id}_path", log, referrer: "duplicate_logs", remaining_duplicate_id:)
  end
end
