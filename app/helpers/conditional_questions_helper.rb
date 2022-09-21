module ConditionalQuestionsHelper
  def conditional_questions_for_page(page)
    page.questions.map(&:conditional_for).compact.map(&:keys).flatten
  end

  def find_conditional_question(page, question, answer_value)
    return if question.conditional_for.nil?

    conditional_key = question.conditional_for.find { |_, conditional_value|
      conditional_value.map(&:to_s).include? answer_value.to_s
    }&.first
    page.questions.find { |q| q.id == conditional_key }
  end

  def display_question_key_div(page, question)
    "style='display:none;'".html_safe if conditional_questions_for_page(page).include?(question.id) || question.requires_js
  end
end
