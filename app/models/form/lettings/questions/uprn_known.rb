class Form::Lettings::Questions::UprnKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn_known"
    @copy_key = "lettings.property_information.uprn.uprn_known"
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
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  def unanswered_error_message
    I18n.t("validations.property.uprn_known.invalid")
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 11, 2024 => 12, 2025 => 16, 2026 => 16 }.freeze
end
