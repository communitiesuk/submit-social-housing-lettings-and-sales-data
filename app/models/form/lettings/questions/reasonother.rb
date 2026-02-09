class Form::Lettings::Questions::Reasonother < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reasonother"
    @copy_key = "lettings.household_situation.reason.#{@page.id}.reasonother"
    @type = "text"
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 77, 2024 => 76, 2025 => 76, 2026 => 76 }.freeze
end
