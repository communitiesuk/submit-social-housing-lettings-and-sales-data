class CheckAnswersSummaryListCardComponent < ViewComponent::Base
  attr_reader :questions, :log, :user

  def initialize(questions:, log:, user:)
    @questions = questions
    @log = log
    @user = user
    super
  end

  def applicable_questions
    questions.reject { |q| q.hidden_in_check_answers?(log, user) }
  end

  def get_answer_label(question)
    answer = Answer.new(question:, log:)
    answer.answer_label.presence || "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
  end
end
