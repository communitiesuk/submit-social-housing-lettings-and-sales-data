class Form::Sales::Questions::HandoverDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hodate"
    @copy_key = "sales.sale_information.handover_date"
    @type = "date"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 82, 2024 => 84, 2025 => 76, 2026 => 84 }.freeze
end
