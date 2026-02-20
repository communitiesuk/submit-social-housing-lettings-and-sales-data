class Form::Lettings::Questions::TenantCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancycode"
    @type = "text"
    @width = 10
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR) if form.start_date.present?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 7, 2024 => 9, 2025 => 9, 2026 => 9 }.freeze
end
