class Form::Sales::Questions::OtherOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "othtype"
    @copy_key = "sales.setup.type.outright_ownership.othtype"
    @type = "text"
    @width = 10
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 6, 2024 => 8 }.freeze
end
