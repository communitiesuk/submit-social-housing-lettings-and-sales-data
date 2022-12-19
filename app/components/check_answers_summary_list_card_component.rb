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
    question.answer_label(log).presence || "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
  end

  def check_answers_card_title(question)
    case question.form.type
    when "lettings"
      case question.check_answers_card_number
      when 1
        "Lead tenant"
      when 2..8
        "Person #{question.check_answers_card_number}"
      end
    when "sales"
      case log[:jointpur]
      when 1
        case question.check_answers_card_number
        when 1..2
          "Buyer #{question.check_answers_card_number}"
        when 3..6
          "Person #{question.check_answers_card_number - 2}"
        end
      when 2
        case question.check_answers_card_number
        when 1
          "Buyer #{question.check_answers_card_number}"
        when 2..5
          "Person #{question.check_answers_card_number - 1}"
        end
      end
    end
  end
end
