class Form::Sales::Questions::SaleDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "saledate"
    @type = "date"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 1, 2024 => 3, 2025 => 3, 2026 => 3 }.freeze
end
