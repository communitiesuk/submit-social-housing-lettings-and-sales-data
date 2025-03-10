class Form::Lettings::Questions::TenancyStartDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "startdate"
    @type = "date"
    @unresolved_hint_text = "Some scheme details have changed, and now this log needs updating. Check that the tenancy start date is correct."
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max] if form.start_date.present?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 5, 2024 => 7 }.freeze
end
