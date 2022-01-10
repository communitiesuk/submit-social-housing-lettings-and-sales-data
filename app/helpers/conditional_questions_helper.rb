module ConditionalQuestionsHelper
  def conditional_questions_for_page(page)
    page.questions.map(&:conditional_for).compact.map(&:keys).flatten
  end

  def display_question_key_div(page, question)
    "style='display:none;'".html_safe if conditional_questions_for_page(page).include?(question.id) || question.requires_js
  end
end
