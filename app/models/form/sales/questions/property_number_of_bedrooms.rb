class Form::Sales::Questions::PropertyNumberOfBedrooms < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "beds"
    @copy_key = "sales.property_information.beds"
    @type = "numeric"
    @width = 2
    @min = 1
    @max = 9
    @step = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 11, 2024 => 18, 2025 => 17, 2026 => 18 }.freeze
end
