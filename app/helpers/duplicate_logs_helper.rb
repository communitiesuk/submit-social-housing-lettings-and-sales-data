module DuplicateLogsHelper
  include GovukLinkHelper

  def duplicate_logs_continue_button(all_duplicates, duplicate_log, original_log_id)
    if all_duplicates.count > 1
      return govuk_button_link_to "Keep this log and delete duplicates", send("#{duplicate_log.class.name.underscore}_delete_duplicates_path", duplicate_log, original_log_id:)
    end

    if original_log_id == duplicate_log.id
      govuk_button_link_to "Back to Log #{duplicate_log.id}", send("#{duplicate_log.class.name.underscore}_path", duplicate_log)
    else
      return govuk_button_link_to "Back to lettings logs", lettings_logs_path if duplicate_log.lettings?

      govuk_button_link_to "Back to sales logs", sales_logs_path
    end
  end

  def duplicate_logs_action_href(log, page_id, original_log_id)
    send("#{log.model_name.param_key}_#{page_id}_path", log, referrer: "interruption_screen", original_log_id:)
  end
end
