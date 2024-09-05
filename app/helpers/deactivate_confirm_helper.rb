module DeactivateConfirmHelper
  def affected_title(affected_logs, affected_locations)
    title_parts = []
    title_parts << pluralize(affected_logs.count, "log") if affected_logs.count > 0
    title_parts << pluralize(affected_locations.count, "location") if affected_locations.count > 0
    "This change will affect #{title_parts.join(' and ')}."
  end
end
