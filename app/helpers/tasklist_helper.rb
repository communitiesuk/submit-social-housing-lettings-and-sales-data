module TasklistHelper
  STATUSES = {
    :not_started => "Not started",
    :cannot_start_yet =>  "Cannot start yet",
    :completed => "Completed",
    :in_progress => "In progress"
  }

  STYLES = {
    :not_started => "govuk-tag--grey",
    :cannot_start_yet => "govuk-tag--grey",
    :completed => "",
    :in_progress => "govuk-tag--blue"
  }

  def get_subsection_status(subsection_name, case_log)
    @form = Form.new(2021, 2022)
    questions = @form.questions_for_subsection(subsection_name).keys

    if subsection_name == "declaration"
      return all_questions_completed(case_log) ? :not_started : :cannot_start_yet
    end
    if questions.all? {|question| case_log[question].blank?}
      return :not_started
    end
    if questions.all? {|question| case_log[question].present?}
      return :completed
    end
    :in_progress
  end

  def all_questions_completed(case_log)
    case_log.attributes.all? { |_question, answer| answer.present?}
  end

  def get_status_style(status_label)
    STYLES[status_label]
  end

  def get_status_label(status)
    STATUSES[status]
  end
end
