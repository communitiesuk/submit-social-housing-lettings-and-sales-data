class Form::Sales::Questions::GenderSameAsSex < ::Form::Question
  def initialize(id, hsh, page, person_index:, buyer: false)
    super(id, hsh, page)
    @id = "gender_same_as_sex#{person_index}"
    @type = "radio"
    @check_answers_card_number = person_index
    @conditional_for = { "gender_description#{person_index}" => [2] }
    @inferred_check_answers_value = [{ "condition" => { "gender_same_as_sex#{person_index}" => 2 }, "value" => "No" }]
    @person_index = person_index
    @buyer = buyer
    @copy_key = "sales.household_characteristics.gender_same_as_sex#{person_index}.#{buyer ? 'buyer' : 'person'}" if person_index == 2
    @question_number = get_person_question_number(BASE_QUESTION_NUMBERS, override_hash: BUYER_OVERRIDE_QUESTION_NUMBERS)
  end

  BASE_QUESTION_NUMBERS = { 2026 => 32 }.freeze
  BUYER_OVERRIDE_QUESTION_NUMBERS = { 2026 => { 1 => 23, 2 => 32 } }.freeze

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
