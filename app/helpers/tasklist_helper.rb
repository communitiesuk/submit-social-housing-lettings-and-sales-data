module TasklistHelper
  include GovukLinkHelper

  STATUSES = {
    not_started: "Not started",
    cannot_start_yet: "Cannot start yet",
    completed: "Completed",
    in_progress: "In progress",
  }.freeze

  STYLES = {
    not_started: "govuk-tag--grey",
    cannot_start_yet: "govuk-tag--grey",
    completed: "",
    in_progress: "govuk-tag--blue",
  }.freeze

  def get_next_incomplete_section(case_log)
    case_log.form.subsections.find { |subsection| subsection.is_incomplete?(case_log) }
  end

  def get_subsections_count(case_log, status = :all)
    return case_log.form.subsections.count if status == :all

    case_log.form.subsections.count { |subsection| subsection.status(case_log) == status }
  end

  def next_page_or_check_answers(subsection, case_log)
    path = if subsection.is_started?(case_log)
             "case_log_#{subsection.id}_check_answers_path"
           else
             next_page = subsection.pages.first.routed_to?(case_log) ? subsection.pages.first.id : case_log.form.next_page(subsection.pages.first, case_log)
             "case_log_#{next_page}_path"
           end
    send(path, case_log)
  end

  def subsection_link(subsection, case_log)
    if subsection.status(case_log) != :cannot_start_yet
      next_page_path = next_page_or_check_answers(subsection, case_log).to_s
      govuk_link_to(subsection.label, next_page_path.dasherize, aria: { describedby: subsection.id.dasherize })
    else
      subsection.label
    end
  end
end
