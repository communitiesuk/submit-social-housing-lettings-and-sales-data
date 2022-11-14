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
    reactivating_soon: "blue",
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
