class Form::Sales::Questions::SavingsNk < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "savingsnk"
    @copy_key = "sales.income_benefits_and_savings.savings.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}.savingsnk"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "savings" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "savingsnk" => 0,
        },
      ],
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 72, 2024 => 74 }.freeze
end
