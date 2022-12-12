class Form::Sales::Questions::Buyer2AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age2_known"
    @check_answer_label = "Buyer 2’s age"
    @header = "Do you know buyer 2’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @conditional_for = {
      "age2" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age2_known" => 0,
        },
        {
          "age2_known" => 1,
        },
      ],
    }
    @check_answers_card_number = 2
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
