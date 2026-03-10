class Form::Sales::Questions::PurchaserCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "purchid"
    @type = "text"
    @width = 10
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 2, 2024 => 4, 2025 => 4, 2026 => 4 }.freeze
end
