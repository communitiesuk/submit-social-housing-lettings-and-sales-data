class Form::Sales::Questions::PersonAgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person #{person_display_number(PERSON_INDEX)}’s age known?"
    @header = "Do you know person #{person_display_number(PERSON_INDEX)}’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = {
      "age#{person_database_number(PERSON_INDEX)}" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age#{person_database_number(PERSON_INDEX)}_known" => 0,
        },
        {
          "age#{person_database_number(PERSON_INDEX)}_known" => 1,
        },
      ],
    }
    @check_answers_card_number = person_database_number(PERSON_INDEX)
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  PERSON_INDEX = {
    "age2_known" => 2,
    "age3_known" => 3,
    "age4_known" => 4,
    "age5_known" => 5,
    "age6_known" => 6,
  }.freeze
end
