module FormPageHelper
  def action_href(log, page_id)
    send("#{log.model_name.param_key}_#{page_id}_path", log, referrer: "check_answers")
  end
end
