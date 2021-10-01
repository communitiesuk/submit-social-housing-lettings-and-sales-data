module CheckAnswersHelper
  def get_answered_questions_total(subsection_pages, case_log)
    questions = subsection_pages.values.flat_map do |page| 
      page["questions"].keys 
    end
    questions.count { |question| case_log[question].present? }
  end


  def create_update_answer_link(case_log_answer, case_log_id, page)
    link_name = case_log_answer.blank? ? "Answer" : "Change"
    link_to(link_name, "/case_logs/#{case_log_id}/#{page}", class: "govuk-link").html_safe
  end

  def create_next_missing_question_link(case_log_id, subsection_pages, case_log)
      pages_to_fill_in = []
      subsection_pages.each do |page_title, page_info|
        page_info["questions"].any? { |q| case_log["q"].blank?}
        pages_to_fill_in << page_title
      end
      url = "/case_logs/#{case_log_id}/#{pages_to_fill_in.first}"
      link_to('Answer the missing questions', url, class: "govuk-link").html_safe
  end

  def get_total_number_of_questions(subsection_pages)
    questions = subsection_pages.values.flat_map do |page| 
      page["questions"].keys 
    end
    questions.count
  end
end
