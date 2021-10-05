module ConditionalQuestionsHelper
  def conditional_questions_for_page(page)
    page["questions"].values.map { |question|
      question["conditional_for"]
    }.compact.map(&:keys).flatten
  end
end
