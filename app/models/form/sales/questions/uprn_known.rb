class Form::Sales::Questions::UprnKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn_known"
    @check_answer_label = "UPRN known?"
    @header = "Do you know the property's UPRN?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "The Unique Property Reference Number (UPRN) is a unique number system created by Ordnance Survey and used by housing providers and various industries across the UK. An example UPRN is 10010457355.<br><br>
      The UPRN may not be the same as the property reference assigned by your organisation.<br><br>
      If you don’t know the UPRN you can enter the address of the property instead on the next screen."
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
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  def unanswered_error_message
    I18n.t("validations.sales.property_information.uprn_known.invalid")
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 14, 2024 => 15 }.freeze
end
