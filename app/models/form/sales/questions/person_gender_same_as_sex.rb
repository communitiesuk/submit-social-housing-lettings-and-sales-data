class Form::Sales::Questions::PersonGenderSameAsSex < ::Form::Question
  def initialize(id, hsh, page, person_index:, buyer: false)
    super(id, hsh, page)
    @id = "gender_same_as_sex#{person_index}"
    @type = "radio"
    @check_answers_card_number = person_index
    @conditional_for = { "gender_description#{person_index}" => [2] }
    @inferred_check_answers_value = [{ "condition" => { "gender_same_as_sex#{person_index}" => 2 }, "value" => "No" }]
    @person_index = person_index
    @buyer = buyer
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 0 }.freeze

  def answer_options
    {
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No, enter gender identity" },
      "divider" => { "value" => true },
      "3" => { "value" => "#{@buyer ? 'Buyer' : 'Person'} prefers not to say" },
    }.freeze
  end

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == 3

    super
  end
end
