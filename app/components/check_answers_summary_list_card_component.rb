class CheckAnswersSummaryListCardComponent < ViewComponent::Base
  attr_reader :questions, :lettings_log, :user

  def initialize(questions:, lettings_log:, user:)
    @questions = questions
    @lettings_log = lettings_log
    @user = user
    super
  end

  def applicable_questions
    questions.reject { |q| q.hidden_in_check_answers?(lettings_log, user) }
  end

  def get_answer_label(question)
    question.answer_label(lettings_log).presence || "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
  end
end
