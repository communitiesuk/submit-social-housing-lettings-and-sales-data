module TasklistHelper
  def get_subsection_status(subsection_name, case_log)
    @form = Form.new(2021, 2022)
    questions = @form.questions_for_subsection(subsection_name).keys

    if subsection_name == "declaration"
      return all_questions_completed(case_log) ? "Not started" : "Cannot start yet"
    end
    if questions.all? {|question| case_log[question].blank?}
      return "Not started"
    end
    if questions.all? {|question| case_log[question].present?}
      return "Completed"
    end
    "In progress"
  end

  def all_questions_completed(case_log)
    case_log.attributes.all? { |_question, answer| answer.present?}
  end
end
