class Form::Sales::Questions::PersonKnown < Form::Sales::Questions::Person
  def initialize(id, hsh, page, person_index:)
    super
    @check_answer_label = "Details known for person #{person_index}?"
    @header = "Do you know the details for person #{person_index}?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "details_known_#{person_index}" => 1,
        },
      ],
    }
    @check_answers_card_number = person_index + 2
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
