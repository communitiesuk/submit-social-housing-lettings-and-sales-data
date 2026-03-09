class Form::Sales::Questions::GenderDescription < ::Form::Question
  def initialize(id, hsh, page, person_index:, buyer: false)
    super(id, hsh, page)
    @id = "gender_description#{person_index}"
    @type = "text"
    @check_answers_card_number = person_index
    @buyer = buyer
    @person_index = person_index
    @question_number = question_number
  end

  BASE_QUESTION_NUMBERS = { 2026 => 32 }.freeze
  BUYER_OVERRIDE_QUESTION_NUMBERS = { 2026 => { 1 => 23, 2 => 32 } }.freeze
  def question_number
    buyer_override_question_number = BUYER_OVERRIDE_QUESTION_NUMBERS.dig(form.start_date.year,@person_index)

    return buyer_override_question_number if buyer_override_question_number.present? && @buyer

    base_question_number = BASE_QUESTION_NUMBERS[form.start_date.year] || BASE_QUESTION_NUMBERS[BASE_QUESTION_NUMBERS.keys.max]

    base_question_number + (form.person_question_count * @person_index)
  end

  def derived?(log)
    log.public_send("gender_same_as_sex#{@person_index}") != 2
  end
end
