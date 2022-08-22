class CheckAnswersSummaryListCardComponent < ViewComponent::Base
  attr_reader :questions, :case_log, :user

  def initialize(questions:, case_log:, user:)
    @questions = questions
    @case_log = case_log
    @user = user
    super
  end

  def applicable_questions
    questions.reject { |q| q.hidden_in_check_answers?(case_log, user) }
  end

  def get_answer_label(question)
    question.answer_label(case_log).presence || "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
  end
end
