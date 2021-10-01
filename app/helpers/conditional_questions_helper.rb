module ConditionalQuestionsHelper
  def conditional_questions_for_page(page)
    page["questions"].values.map do |question|
      question["conditional_for"]
    end.compact.map(&:keys).flatten
  end
end
