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

  def first_page_or_check_answers(subsection, case_log)
    path = if subsection.is_started?(case_log)
             "case_log_#{subsection.id}_check_answers_path"
           else
             "case_log_#{subsection.applicable_questions(case_log).first.page.id}_path"
           end
    send(path, case_log)
  end

  def subsection_link(subsection, case_log)
    next_page_path = if subsection.status(case_log) != :cannot_start_yet
                       first_page_or_check_answers(subsection, case_log)
                     else
                       "#"
                     end
    govuk_link_to(subsection.label, next_page_path.to_s.dasherize, class: "task-name")
  end
end
