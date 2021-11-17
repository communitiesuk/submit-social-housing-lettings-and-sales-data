module CheckAnswersHelper
  def total_answered_questions(subsection, case_log, form)
    total_questions(subsection, case_log, form).keys.count do |question_key|
      case_log[question_key].present?
    end
  end

  def total_number_of_questions(subsection, case_log, form)
    total_questions(subsection, case_log, form).count
  end

  def total_questions(subsection, case_log, form)
    questions = form.questions_for_subsection(subsection)
    form.filter_conditional_questions(questions, case_log)
  end

  def get_next_page_name(form, page_name, case_log)
    page = form.all_pages[page_name]
    if page.key?("conditional_route_to")
      page["conditional_route_to"].each do |conditional_page_name, condition|
        unless condition.any? { |field, value| case_log[field].blank? || !value.include?(case_log[field]) }
          return conditional_page_name
        end
      end
    end
    form.next_page(page_name)
  end

  def create_update_answer_link(question_title, case_log, form)
    page = form.page_for_question(question_title)
    link_name = case_log[question_title].blank? ? "Answer" : "Change"
    link_to(link_name, "/case_logs/#{case_log.id}/#{page}", class: "govuk-link").html_safe
  end

  def create_next_missing_question_link(case_log_id, subsection, case_log, form)
    pages_to_fill_in = []
    form.pages_for_subsection(subsection).each do |page_title, page_info|
      page_info["questions"].any? { |question| case_log[question].blank? }
      pages_to_fill_in << page_title
    end
    url = "/case_logs/#{case_log_id}/#{pages_to_fill_in.first}"
    link_to("Answer the missing questions", url, class: "govuk-link").html_safe
  end

  def display_answered_questions_summary(subsection, case_log, form)
    if total_answered_questions(subsection, case_log, form) == total_number_of_questions(subsection, case_log, form)
      '<p class="govuk-body govuk-!-margin-bottom-7">You answered all the questions</p>'.html_safe
    else
      "<p class=\"govuk-body govuk-!-margin-bottom-7\">You answered #{total_answered_questions(subsection, case_log, form)} of #{total_number_of_questions(subsection, case_log, form)} questions</p>
      #{create_next_missing_question_link(case_log['id'], subsection, case_log, form)}".html_safe
    end
  end
end
