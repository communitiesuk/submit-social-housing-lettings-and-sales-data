module ConditionalQuestionsHelper
  def conditional_questions_for_page(page)
    page.questions.map(&:conditional_for).compact.map(&:keys).flatten
  end

  def find_conditional_question(page, conditional_for, answer_value)
    return if conditional_for.nil?

    conditional_key = conditional_for.find { |_, conditional_value| conditional_value.include? answer_value }&.first
    page.questions.find { |q| q.id == conditional_key }
  end

  def display_question_key_div(page, question)
    "style='display:none;'".html_safe if conditional_questions_for_page(page).include?(question.id) || question.requires_js
  end
end
