module CheckAnswersHelper
  include GovukLinkHelper

  def display_answered_questions_summary(subsection, case_log)
    total = subsection.applicable_questions_count(case_log)
    answered = subsection.answered_questions_count(case_log)
    if total == answered
      '<p class="govuk-body">You answered all the questions.</p>'.html_safe
    else
      "<p class=\"govuk-body\">You have answered #{answered} of #{total} questions.</p>".html_safe
    end
  end

  def get_answer_label(question, case_log)
    unless question.id == "earnings"
      answer = question.prefix == "£" ? ActionController::Base.helpers.number_to_currency(question.answer_label(case_log), delimiter: ",", format: "%n") : question.answer_label(case_log)
      if answer.present? 
        [question.prefix, answer, question.suffix].join("")
      else
        "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
      end
    else
      linked_question = case_log.form.get_question("incfreq")
      if(question.answer_label(case_log).present? && linked_question.answer_label(case_log).present?)
        suffix = case linked_question.answer_label(case_log)
        when "Weekly"
          " every week"
        when "Monthly"
          " every month"
        when "Yearly"
          " every year"
        end
        [question.prefix, question.answer_label(case_log), suffix].join("")
      else
        "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
      end
    end
  end
end
