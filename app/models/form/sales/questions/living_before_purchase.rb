class Form::Sales::Questions::LivingBeforePurchase < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "proplen_asked"
    @check_answer_label = "Buyer lived in the property before purchasing"
    @header = "Did the buyer live in the property before purchasing it?"
    @hint_text = nil
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "proplen" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "proplen_asked" => 0,
        },
      ],
    }
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  def question_number
    case @ownershipsch
    when 1
      75
    when 2
      99
    end
  end
end
