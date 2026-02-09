class Form::Lettings::Questions::PreviousTenureRenewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevten"
    @copy_key = "lettings.household_situation.prevten.renewal"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options =  form.start_year_2025_or_later? ? ANSWER_OPTIONS_2025 : ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "34" => { "value" => "Specialist retirement housing" },
    "36" => { "value" => "Sheltered housing for adults aged under 55 years" },
    "35" => { "value" => "Extra care housing" },
    "6" => { "value" => "Other supported housing" },
  }.freeze

  ANSWER_OPTIONS_2025 = {
    "35" => { "value" => "Extra care housing" },
    "38" => { "value" => "Older people’s housing for tenants with low support needs" },
    "6" => { "value" => "Other supported housing" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 78, 2024 => 77, 2025 => 77, 2026 => 84 }.freeze
end
