class Form::Sales::Questions::PersonKnown < Form::Sales::Questions::Person
  def initialize(id, hsh, page, person_index:)
    super
    @check_answer_label = "Details known for person #{person_display_number}?"
    @header = "Do you know the details for person #{person_display_number}?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = ""
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          field_for_person("details_known_") => 1,
        },
      ],
    }
    @check_answers_card_number = person_index
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
