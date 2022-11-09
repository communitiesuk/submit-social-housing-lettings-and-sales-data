module TagHelper
  include GovukComponentsHelper

  TEXT = {
    not_started: "Not started",
    cannot_start_yet: "Cannot start yet",
    in_progress: "In progress",
    completed: "Completed",
    active: "Active",
    incomplete: "Incomplete",
    deactivates_soon: "Deactivates soon",
    reactivates_soon: "Reactivates soon",
    deactivated: "Deactivated",
  }.freeze

  COLOUR = {
    not_started: "grey",
    cannot_start_yet: "grey",
    in_progress: "blue",
    completed: "green",
    active: "green",
    incomplete: "red",
    deactivates_soon: "yellow",
    reactivates_soon: "blue",
    deactivated: "grey",
  }.freeze

  def status_tag(status, classes = [])
    govuk_tag(
      classes:,
      colour: COLOUR[status.to_sym],
      text: TEXT[status.to_sym],
    )
  end
end
