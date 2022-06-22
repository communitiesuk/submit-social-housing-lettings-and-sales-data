module CheckAnswersHelper
  include GovukLinkHelper

  def display_answered_questions_summary(subsection, case_log, current_user)
    total = total_count(subsection, case_log, current_user)
    answered = answered_questions_count(subsection, case_log, current_user)
    if total == answered
      '<p class="govuk-body">You answered all the questions.</p>'.html_safe
    else
      "<p class=\"govuk-body\">You have answered #{answered} of #{total} questions.</p>".html_safe
    end
  end

private

  def answered_questions_count(subsection, case_log, current_user)
    answered_questions(subsection, case_log, current_user).count
  end

  def answered_questions(subsection, case_log, current_user)
    total_applicable_questions(subsection, case_log, current_user).select { |q| q.completed?(case_log) }
  end

  def total_count(subsection, case_log, current_user)
    total_applicable_questions(subsection, case_log, current_user).count
  end

  def total_applicable_questions(subsection, case_log, current_user)
    subsection.applicable_questions(case_log).reject { |q| q.hidden_in_check_answers?(case_log, current_user) }
  end

  def get_answer_label(question, case_log)
    question.answer_label(case_log).presence || "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
  end
end
