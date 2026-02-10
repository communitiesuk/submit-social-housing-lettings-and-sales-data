class Form::Lettings::Questions::TenancyStartDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "startdate"
    @type = "date"
    @unresolved_hint_text = "Some scheme details have changed, and now this log needs updating. Check that the tenancy start date is correct."
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR) if form.start_date.present?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 5, 2024 => 7, 2025 => 7, 2026 => 7 }.freeze
end
