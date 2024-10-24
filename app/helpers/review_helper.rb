module ReviewHelper
  include CollectionTimeHelper

  def review_log_info_text(log)
    if log.collection_period_open?
      "You can review and make changes to this log until #{log.form.submission_deadline.to_formatted_s(:govuk_date)}.".html_safe
    else
      start_year = log.startdate ? collection_start_year_for_date(log.startdate) : log.form.start_date.year
      "This log is from the #{start_year} to #{start_year + 1} collection window, which is now closed."
    end
  end

  def review_breadcrumbs(log)
    if log.collection_closed_for_editing?
      content_for :breadcrumbs, govuk_breadcrumbs(breadcrumbs: {
        "Home" => root_path,
        breadcrumb_logs_title(log, current_user) => breadcrumb_logs_link(log, current_user),
      })
    else
      content_for :breadcrumbs, govuk_breadcrumbs(breadcrumbs: {
        "Home" => root_path,
        breadcrumb_logs_title(log, current_user) => breadcrumb_logs_link(log, current_user),
        "Log #{log.id}" => url_for(log),
      })
    end
  end
end
