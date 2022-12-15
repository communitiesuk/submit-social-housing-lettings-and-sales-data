class Form::Sales::Questions::PersonAgeKnown < ::Form::Sales::Questions::Person
  def initialize(id, hsh, page, person_index)
    super(id, hsh, page, person_index)
    @check_answer_label = "Person #{person_display_number}’s age known?"
    @header = "Do you know person #{person_display_number}’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = {
      "age#{@person_index}" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age#{@person_index}_known" => 0,
        },
        {
          "age#{@person_index}_known" => 1,
        },
      ],
    }
    @check_answers_card_number = @person_index
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  # PERSON_INDEX = {
  #   "age2_known" => 2,
  #   "age3_known" => 3,
  #   "age4_known" => 4,
  #   "age5_known" => 5,
  #   "age6_known" => 6,
  # }.freeze
end
