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
    {
      lettings: lettings_duplicate_sets_from_collection(LettingsLog.created_by(user), user.organisation),
      sales: sales_duplicate_sets_from_collection(SalesLog.created_by(user), user.organisation),
    }
  end

  def duplicates_for_organisation(organisation)
    {
      lettings: lettings_duplicate_sets_from_collection(LettingsLog.filter_by_organisation(organisation), organisation),
      sales: sales_duplicate_sets_from_collection(SalesLog.filter_by_organisation(organisation), organisation),
    }
  end

  def sales_duplicate_sets_from_collection(logs, organisation)
    duplicate_sets = []
    duplicate_ids_seen = Set.new

    logs.visible.each do |log|
      next if duplicate_ids_seen.include?(log.id)

      duplicates = SalesLog.filter_by_organisation(organisation).duplicate_logs(log)
      next if duplicates.none?

      duplicate_ids = [log.id, *duplicates.map(&:id)]
      duplicate_sets << duplicate_ids
      duplicate_ids_seen.merge(duplicate_ids)
    end

    duplicate_sets
  end

  def lettings_duplicate_sets_from_collection(logs, organisation)
    duplicate_sets = []
    duplicate_ids_seen = Set.new

    logs.visible.each do |log|
      next if duplicate_ids_seen.include? log.id

      duplicates = LettingsLog.filter_by_organisation(organisation).duplicate_logs(log)
      next if duplicates.none?

      duplicate_ids = [log.id, *duplicates.map(&:id)]
      duplicate_sets << duplicate_ids
      duplicate_ids_seen.merge duplicate_ids
    end

    duplicate_sets
  end

  def duplicate_sets_count(user, organisation)
    duplicates = if user.support?
                   duplicates_for_organisation(organisation)
                 elsif user.data_coordinator?
                   duplicates_for_organisation(user.organisation)
                 elsif user.data_provider?
                   duplicates_for_user(user)
                 end

    duplicates[:lettings].count + duplicates[:sales].count
  end
end
