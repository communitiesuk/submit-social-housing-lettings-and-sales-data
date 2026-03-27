class Form::Sales::Questions::ArmedForcesSpouse < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "armedforcesspouse"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "4" => { "value" => "Yes" },
    "5" => { "value" => "No" },
    "6" => { "value" => "Buyer prefers not to say" },
    "divider" => { "value" => true },
    "7" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 64, 2024 => 66, 2025 => 63, 2026 => 71 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "6"

    super
  end
end
