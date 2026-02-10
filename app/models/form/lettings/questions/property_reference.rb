class Form::Lettings::Questions::PropertyReference < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "propcode"
    @type = "text"
    @width = 10
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR) if form.start_date.present?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 8, 2024 => 10, 2025 => 10, 2026 => 10 }.freeze
end
