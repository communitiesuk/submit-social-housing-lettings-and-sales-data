class Form::Lettings::Questions::PersonSexRegisteredAtBirth < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "radio"
    @check_answers_card_number = person_index
    @answer_options = ANSWER_OPTIONS
    @person_index = person_index
    @question_number = question_number
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "divider" => { "value" => true },
    "R" => { "value" => "Person prefers not to say" },
  }.freeze

  def question_number
    base_question_number = 29

    base_question_number + (5 * @person_index)
  end

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "R"

    super
  end
end
