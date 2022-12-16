class Form::Sales::Questions::PersonAgeKnown < ::Form::Sales::Questions::Person
  def initialize(id, hsh, page, person_index:)
    super
    @check_answer_label = "Person #{person_display_number}’s age known?"
    @header = "Do you know person #{person_display_number}’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = {
      field_for_person("age") => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          field_for_person("age", "_known") => 0,
        },
        {
          field_for_person("age", "_known") => 1,
        },
      ],
    }
    @check_answers_card_number = @person_index
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
