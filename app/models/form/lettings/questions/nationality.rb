class Form::Lettings::Questions::Nationality < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "national"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "18" => { "value" => "United Kingdom" },
    "17" => { "value" => "Republic of Ireland" },
    "19" => { "value" => "European Economic Area (EEA) country, excluding Ireland" },
    "20" => { "value" => "Afghanistan" },
    "21" => { "value" => "Ukraine" },
    "12" => { "value" => "Other" },
    "divider" => true,
    "13" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 36, 2024 => 35, 2025 => 35, 2026 => 35 }.freeze
end
