class Form::Sales::Questions::GenderDescription < ::Form::Question
  def initialize(id, hsh, page, person_index:, buyer: false)
    super(id, hsh, page)
    @id = "gender_description#{person_index}"
    @type = "text"
    @check_answers_card_number = person_index
    @buyer = buyer
    @person_index = person_index
    @question_number = get_person_question_number(BASE_QUESTION_NUMBERS, override_hash: BUYER_OVERRIDE_QUESTION_NUMBERS)
  end

  BASE_QUESTION_NUMBERS = { 2026 => 32 }.freeze
  BUYER_OVERRIDE_QUESTION_NUMBERS = { 2026 => { 1 => 23, 2 => 32 } }.freeze

  def derived?(log)
    log.public_send("gender_same_as_sex#{@person_index}") != 2
  end
end
