class Form::Sales::Questions::UprnKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn_known"
    @copy_key = "sales.property_information.uprn.uprn_known"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "uprn" => [1] }
    @inferred_check_answers_value = [
      {
        "condition" => { "uprn_known" => 0 },
        "value" => "Not known",
      },
    ]
    @hidden_in_check_answers = {
      "depends_on" => [
        { "uprn_known" => 0 },
        { "uprn_known" => 1 },
      ],
    }
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  def unanswered_error_message
    I18n.t("validations.sales.property_information.uprn_known.invalid")
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 14, 2024 => 15, 2025 => 13, 2026 => 13 }.freeze
end
