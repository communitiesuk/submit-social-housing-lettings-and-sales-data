class Form::Lettings::Questions::TenancyOther < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancyother"
    @copy_key = "lettings.tenancy_information.tenancy.#{page.id}.tenancyother"
    @type = "text"
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 27, 2024 => 27, 2025 => 28, 2026 => 27 }.freeze
end
