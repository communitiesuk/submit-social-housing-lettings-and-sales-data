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
  }.freeze

  COLOUR = {
    not_started: "grey",
    cannot_start_yet: "grey",
    in_progress: "blue",
    completed: "green",
    active: "green",
    incomplete: "red",
    deactivating_soon: "yellow",
    activating_soon: "blue",
    reactivating_soon: "blue",
    deactivated: "grey",
    deleted: "red",
    merged: "green",
  }.freeze

  def status_tag(status, classes = [])
    govuk_tag(
      classes:,
      colour: COLOUR[status.to_sym],
      text: TEXT[status.to_sym],
    )
  end

  def status_tag_from_resource(resource, classes = [])
    status = resource.status
    status = :active if resource.deactivates_in_a_long_time?
    status_tag(status, classes)
  end
end
