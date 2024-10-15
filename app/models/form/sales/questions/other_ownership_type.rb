class Form::Sales::Questions::OtherOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "othtype"
    @copy_key = "sales.setup.type.outright_ownership.othtype"
    @type = "text"
    @width = 10
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 6, 2024 => 8 }.freeze
end
