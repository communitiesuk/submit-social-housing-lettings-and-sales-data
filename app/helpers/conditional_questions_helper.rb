module ConditionalQuestionsHelper
  def conditional_questions_for_page(page)
    page["questions"].values.map { |question|
      question["conditional_for"]
    }.compact.map(&:keys).flatten
  end

  def display_question_key_div(page_info, question_key)
    "style='display:none;'".html_safe if conditional_questions_for_page(page_info).include?(question_key)
  end

  def conditional_html_attributes(question)
    return {} unless question["conditional_for"].present?

    {
      "data-controller": "conditional-question",
      "data-action": "conditional-question#displayConditional",
      "data-info": question["conditional_for"].to_json
    }
  end
end
