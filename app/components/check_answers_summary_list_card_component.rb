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
    question.answer_label(log, user).presence || unanswered_value
  end

  def get_question_label(question)
    [question.question_number_string, question.check_answer_label.to_s.presence || question.header.to_s].compact.join(" - ")
  end

  def check_answers_card_title(question)
    return "Lead tenant" if question.form.type == "lettings" && question.check_answers_card_number == 1
    return "Buyer #{question.check_answers_card_number}" if question.check_answers_card_number <= number_of_buyers

    "Person #{question.check_answers_card_number}"
  end

private

  def unanswered_value
    if bulk_uploaded?
      "<span class=\"app-!-colour-red\">You still need to answer this question</span>".html_safe
    else
      "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
    end
  end

  def bulk_uploaded?
    log.bulk_upload
  end

  def number_of_buyers
    log[:jointpur] == 1 ? 2 : 1
  end
end
