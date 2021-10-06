module ConditionalQuestionsHelper
  def conditional_questions_for_page(page)
    page["questions"].values.map { |question|
      question["conditional_for"]
    }.compact.map(&:keys).flatten
  end

  def display_question_key_div(page_info, question_key)
    "style='display:none;'" if conditional_questions_for_page(page_info).include?(question_key)
  end
end
