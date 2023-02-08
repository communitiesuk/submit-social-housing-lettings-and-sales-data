class Form::Sales::Questions::PersonAgeKnown < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @check_answer_label = "Person #{person_index}’s age known?"
    @header = "Do you know person #{person_index}’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "age#{person_index}" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age#{person_index}_known" => 0,
        },
        {
          "age#{person_index}_known" => 1,
        },
      ],
    }
    @check_answers_card_number = person_index
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
