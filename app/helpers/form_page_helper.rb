module FormPageHelper
  def action_href(log, page_id, referrer = "check_answers")
    send("#{log.model_name.param_key}_#{page_id}_path", log, referrer:)
  end
end
