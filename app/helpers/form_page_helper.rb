module FormPageHelper
  def action_href(log, page_id, referrer = "check_answers")
    send("#{log.model_name.param_key}_#{page_id}_path", log, referrer:)
  end

  def returning_to_question_page?(page, referrer)
    page.interruption_screen? || referrer == "check_answers"
  end

  def accessed_from_duplicate_logs?(referrer)
    %w[duplicate_logs duplicate_logs_banner].include?(referrer)
  end

  def form_page_breadcrumbs(current_user, log, subsection, query_parameters)
    if accessed_from_duplicate_logs?(query_parameters["referrer"])
      content_for :breadcrumbs, govuk_breadcrumbs(breadcrumbs: {
        breadcrumb_logs_title(log, current_user) => breadcrumb_logs_link(log, current_user),
        "Duplicate Logs" => duplicate_logs_path,
        "Duplicates of Log #{log.id}" => send("#{log.class.name.underscore}_duplicate_logs_path", log, original_log_id: query_parameters["original_log_id"]),
      })
    else
      content_for :breadcrumbs, govuk_breadcrumbs(breadcrumbs: {
        breadcrumb_logs_title(log, current_user) => breadcrumb_logs_link(log, current_user),
        "Log #{log.id}" => url_for(log),
        subsection.label => send("#{log.class.name.underscore}_#{subsection.id}_check_answers_path", log),
      })
    end
  end
end
