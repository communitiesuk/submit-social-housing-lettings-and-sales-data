class Form::Sales::Questions::PersonGenderSameAsSex < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "gender_same_as_sex#{person_index}"
    @type = "radio"
    @check_answers_card_number = person_index
    @conditional_for = { "gender_description#{person_index}" => [2] }
    @inferred_check_answers_value = [{ "condition" => { "gender_same_as_sex#{person_index}" => 2 }, "value" => "No" }]
    @person_index = person_index
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No, enter gender identity" },
    "divider" => { "value" => true },
    "3" => { "value" => "Person prefers not to say" },
  }.freeze

  def answer_options
    ANSWER_OPTIONS
  end

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 0 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == 3

    super
  end
end
