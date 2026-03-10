class Form::Sales::Questions::Buyer1Nationality < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "national"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 1
    @inferred_check_answers_value = [{
      "condition" => {
        "national" => 13,
      },
      "value" => "Prefers not to say",
    }]
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "18" => { "value" => "United Kingdom" },
    "17" => { "value" => "Republic of Ireland" },
    "19" => { "value" => "European Economic Area (EEA), excluding ROI" },
    "12" => { "value" => "Other" },
    "13" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 24, 2024 => 26, 2025 => 24, 2026 => 26 }.freeze
end
