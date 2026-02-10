class Form::Lettings::Questions::GenderIdentity1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sex1"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "X" => { "value" => "Non-binary" },
    "divider" => { "value" => true },
    "R" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 33, 2024 => 32, 2025 => 32, 2026 => 31 }.freeze
end
