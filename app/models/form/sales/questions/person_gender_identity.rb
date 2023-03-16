class Form::Sales::Questions::PersonGenderIdentity < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @check_answer_label = "Person #{person_index}’s gender identity"
    @header = "Which of these best describes Person #{person_index}’s gender identity?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = person_index
    @inferred_check_answers_value = [{
      "condition" => {
        id => "R",
      },
      "value" => "Prefers not to say",
    }]
    @question_number = 30 + (4 * person_index)
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "X" => { "value" => "Non-binary" },
    "R" => { "value" => "Person prefers not to say" },
  }.freeze
end
