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
end
