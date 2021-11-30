module CheckAnswersHelper
  include GovukLinkHelper

  def display_answered_questions_summary(subsection, case_log)
    total = subsection.applicable_questions_count(case_log)
    answered = subsection.answered_questions_count(case_log)
    if total == answered
      '<p class="govuk-body govuk-!-margin-bottom-7">You answered all the questions</p>'.html_safe
    else
      "<p class=\"govuk-body govuk-!-margin-bottom-7\">You answered #{answered} of #{total} questions</p>
      #{create_next_missing_question_link(subsection, case_log)}".html_safe
    end
  end

private

  def create_next_missing_question_link(subsection, case_log)
    pages_to_fill_in = subsection.unanswered_questions(case_log).map(&:page)
    url = "/case_logs/#{case_log.id}/#{pages_to_fill_in.first.id}"
    govuk_link_to("Answer the missing questions", url).html_safe
  end
end
