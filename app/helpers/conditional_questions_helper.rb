module ConditionalQuestionsHelper
  def conditional_questions_for_page(page)
    page["questions"].values.map { |question|
      question["conditional_for"]
    }.compact.map(&:keys).flatten
  end

  def display_question_key_div(page_info, question_key)
    if conditional_questions_for_page(page_info).include?(question_key)
      "<div id=#{question_key}_div style='display:none;'>".html_safe
    else
      "<div id=#{question_key}_div>".html_safe
    end
  end
end
