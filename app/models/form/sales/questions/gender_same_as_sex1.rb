class Form::Sales::Questions::GenderSameAsSex1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "gender_same_as_sex1"
    @type = "radio"
    @check_answers_card_number = 1
    @conditional_for = { "gender_description1" => [2] }
    @inferred_check_answers_value = [{ "condition" => { "gender_same_as_sex1" => 2 }, "value" => "No" }]
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No, enter gender identity" },
    "divider" => { "value" => true },
    "3" => { "value" => "Buyer prefers not to say" },
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
