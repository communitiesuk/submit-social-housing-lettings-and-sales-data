class Form::Sales::Questions::LivingBeforePurchase < ::Form::Question
  def initialize(id, hsh, page, question_number:)
    super(id, hsh, page)
    @id = "proplen_asked"
    @check_answer_label = "Buyer lived in the property before purchasing"
    @header = "#{question_number} - Did the buyer live in the property before purchasing it?"
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
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
