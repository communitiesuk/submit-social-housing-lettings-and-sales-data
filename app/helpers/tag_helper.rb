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
  }.freeze

  def status_tag(resource, classes = [])
    display_status = resource.status
    display_status = :active if resource.deactivates_in_more_than_6_months?
    govuk_tag(
      classes:,
      colour: COLOUR[display_status.to_sym],
      text: TEXT[display_status.to_sym],
    )
  end
end
