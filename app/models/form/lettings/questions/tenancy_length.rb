class Form::Lettings::Questions::TenancyLength < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancylength"
    @copy_key = "lettings.tenancy_information.tenancylength.#{page.id}"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @step = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 28, 2024 => 28, 2025 => 29, 2026 => 28 }.freeze
end
