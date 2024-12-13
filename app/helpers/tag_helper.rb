module TagHelper
  include GovukComponentsHelper

  TEXT = {
    not_started: "Not started",
    cannot_start_yet: "Cannot start yet",
    in_progress: "In progress",
    completed: "Completed",
    active: "Active",
    incomplete: "Incomplete",
    deactivating_soon: "Deactivating soon",
    activating_soon: "Activating soon",
    reactivating_soon: "Reactivating soon",
    deactivated: "Deactivated",
    deleted: "Deleted",
    merged: "Merged",
    unconfirmed: "Unconfirmed",
    merge_issues: "Merge issues",
    request_merged: "Merged",
    ready_to_merge: "Ready to merge",
    processing: "Processing",
    blank_template: "Blank template",
    wrong_template: "Wrong template used",
    important_errors: "Errors on important questions in CSV",
    critical_errors: "Critical errors in CSV",
    potential_errors: "Potential errors in CSV",
    logs_uploaded_with_errors: "Logs uploaded with errors",
    errors_fixed_in_service: "Errors fixed on site",
    logs_uploaded_no_errors: "Logs uploaded with no errors",
  }.freeze

  COLOUR = {
    not_started: "light-blue",
    in_progress: "blue",
    completed: "green",
    active: "green",
    incomplete: "red",
    deactivating_soon: "yellow",
    activating_soon: "blue",
    reactivating_soon: "blue",
    deactivated: "grey",
    deleted: "red",
    merged: "orange",
    unconfirmed: "blue",
    merge_issues: "orange",
    request_merged: "green",
    ready_to_merge: "blue",
    processing: "yellow",
    blank_template: "red",
    wrong_template: "red",
    important_errors: "red",
    critical_errors: "red",
    potential_errors: "red",
    logs_uploaded_with_errors: "blue",
    errors_fixed_in_service: "green",
    logs_uploaded_no_errors: "green",
  }.freeze

  def status_tag(status, classes = [])
    return nil if COLOUR[status.to_sym].nil?

    govuk_tag(
      classes:,
      colour: COLOUR[status.to_sym],
      text: TEXT[status.to_sym],
    )
  end

  def status_text(status)
    TEXT[status.to_sym]
  end

  def status_tag_from_resource(resource, classes = [])
    status = resource.status
    status = :active if resource.deactivates_in_a_long_time?
    status_tag(status, classes)
  end
end
