class Form::Lettings::Questions::TenantCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancycode"
    @type = "text"
    @width = 10
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max] if form.start_date.present?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 7, 2024 => 9 }.freeze
end
