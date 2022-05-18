module TagHelper
  include GovukComponentsHelper

  TEXT = {
    not_started: "Not started",
    cannot_start_yet: "Cannot start yet",
    in_progress: "In progress",
    completed: "Completed",
  }.freeze

  COLOUR = {
    not_started: "grey",
    cannot_start_yet: "grey",
    in_progress: "blue",
    completed: "green",
  }.freeze

  def status_tag(status, classes = [])
    govuk_tag(
      classes:,
      colour: COLOUR[status.to_sym],
      text: TEXT[status.to_sym],
    )
  end
end
