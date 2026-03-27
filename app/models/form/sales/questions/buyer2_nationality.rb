class Form::Sales::Questions::Buyer2Nationality < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "nationalbuy2"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "18" => { "value" => "United Kingdom" },
    "17" => { "value" => "Republic of Ireland" },
    "19" => { "value" => "European Economic Area (EEA), excluding ROI" },
    "12" => { "value" => "Other" },
    "13" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 32, 2024 => 34, 2025 => 32 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "13"

    super
  end
end
