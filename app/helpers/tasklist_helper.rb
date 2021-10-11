module TasklistHelper
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

  def get_subsection_status(subsection_name, case_log, questions)
    if subsection_name == "declaration"
      return all_questions_completed(case_log) ? :not_started : :cannot_start_yet
    end

    return :not_started if questions.all? { |question| case_log[question].blank? }
    return :completed if questions.all? { |question| case_log[question].present? }

    :in_progress
  end

  def get_next_incomplete_section(form, case_log)
    subsections = form.all_subsections.keys
    subsections.find { |subsection| is_incomplete?(subsection, case_log, form.questions_for_subsection(subsection).keys) }
  end

  def get_sections_count(form, case_log, status = :all)
    subsections = form.all_subsections.keys
    return subsections.count if status == :all

    subsections.count { |subsection| get_subsection_status(subsection, case_log, form.questions_for_subsection(subsection).keys) == status }
  end

  def get_first_page_or_check_answers(subsection, case_log, form, questions)
    if is_started?(subsection, case_log, questions)
      send("case_log_#{subsection}_check_answers_path", case_log)
    else
      send("case_log_#{form.first_page_for_subsection(subsection)}_path", case_log)
    end
  end

private

  def all_questions_completed(case_log)
    case_log.attributes.all? { |_question, answer| answer.present? }
  end

  def is_incomplete?(subsection, case_log, questions)
    status = get_subsection_status(subsection, case_log, questions)
    %i[not_started in_progress].include?(status)
  end

  def is_started?(subsection, case_log, questions)
    status = get_subsection_status(subsection, case_log, questions)
    %i[in_progress completed].include?(status)
  end
end
