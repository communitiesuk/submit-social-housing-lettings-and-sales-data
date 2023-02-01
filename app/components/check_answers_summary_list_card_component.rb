class CheckAnswersSummaryListCardComponent < ViewComponent::Base
  attr_reader :questions, :log, :user, :bulk_upload

  def initialize(questions:, log:, user:, bulk_upload: nil)
    @questions = questions
    @log = log
    @user = user
    @bulk_upload = bulk_upload

    super
  end

  def applicable_questions
    questions.reject { |q| q.hidden_in_check_answers?(log, user) }
  end

  def get_answer_label(question)
    question.answer_label(log, user).presence || unanswered_value
  end

  def check_answers_card_title(question)
    if question.form.type == "lettings"
      case question.check_answers_card_number
      when 1
        "Lead tenant"
      when 2..8
        "Person #{question.check_answers_card_number}"
      end
    else
      case question.check_answers_card_number
      when 1..number_of_buyers
        "Buyer #{question.check_answers_card_number}"
      when (number_of_buyers + 1)..(number_of_buyers + 4)
        "Person #{question.check_answers_card_number - number_of_buyers}"
      end
    end
  end

private

  def unanswered_value
    if bulk_upload
      "<span class=\"app-!-colour-red\">You still need to answer this question</span>".html_safe
    else
      "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
    end
  end

  def number_of_buyers
    log[:jointpur] == 1 ? 2 : 1
  end
end
