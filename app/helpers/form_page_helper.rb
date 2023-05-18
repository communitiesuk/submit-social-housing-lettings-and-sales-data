module FormPageHelper
  def action_href(log, page_id, referrer = "check_answers")
    if FeatureToggle.not_started_status_removed?
      if log.is_a? SalesLog
        send("#{log.model_name.param_key}_#{page_id}_path", sales_log_id: (log.id || "new"), referrer:)
      else
        send("#{log.model_name.param_key}_#{page_id}_path", lettings_log_id: (log.id || "new"), referrer:)
      end
    else
      send("#{log.model_name.param_key}_#{page_id}_path", log, referrer:)
    end
  end

  def page_back_link(log:, page:, user:, referrer:)
    if FeatureToggle.not_started_status_removed?
      govuk_back_link(href: send(*log.form.previous_page_redirect_path(page, log, user, referrer)))
    else
      govuk_back_link(href: send(*log.form.previous_page_redirect_path(page, log, current_user, referrer)))
    end
  end

  def page_cancel_link(page:, log:)
    if FeatureToggle.not_started_status_removed?
      if log.sales?
        govuk_link_to "Cancel", send(log.form.cancel_path(page, log), sales_log_id: log.id || "new")
      else
        govuk_link_to "Cancel", send(log.form.cancel_path(page, log), lettings_log_id: log.id || "new")
      end
    else
      govuk_link_to "Cancel", send(log.form.cancel_path(page, log), log)
    end
  end

  def page_skip_link(page:, log:, user:)
    link = (page.skip_href(log) || (
      if FeatureToggle.not_started_status_removed?
        if log.sales?
          send(log.form.next_page_redirect_path(page, log, user), sales_log_id: log.id || "new")
        else
          send(log.form.next_page_redirect_path(page, log, user), lettings_log_id: log.id || "new")
        end
      else
        send(log.form.next_page_redirect_path(page, log, user), log)
      end
    ))

    govuk_link_to(
      page.skip_text || "Skip for now",
      link,
    )
  end
end
