class Form::Sales::Questions::HasManagementFee < ::Form::Question
  def initialize(id, hsh, subsection)
    super
    @id = "has_management_fee"
    @copy_key = "sales.sale_information.management_fee.has_management_fee"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "management_fee" => [1],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "has_management_fee" => 1,
        },
      ],
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "0" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 89 }.freeze
end
