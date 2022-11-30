module UnresolvedLogHelper
  def flash_notice_for_resolved_logs(count)
    notice_message = "You’ve updated all the fields affected by the scheme change.</br>"
    notice_message << " <a href=\"/lettings-logs/update-logs\">Update #{count} more #{'log'.pluralize(count)}</a>" if count.positive?
    notice_message
  end
end
