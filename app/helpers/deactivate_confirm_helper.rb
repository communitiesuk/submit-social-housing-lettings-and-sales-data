module DeactivateConfirmHelper
  def affected_title(affected_logs, affected_locations)
    title_parts = []
    title_parts << pluralize(affected_logs.count, "log") if affected_logs.count.positive?
    title_parts << pluralize(affected_locations.count, "location") if affected_locations.count.positive?
    "This change will affect #{title_parts.join(' and ')}."
  end
end
