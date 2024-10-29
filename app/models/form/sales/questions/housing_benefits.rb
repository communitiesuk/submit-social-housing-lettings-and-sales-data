class Form::Sales::Questions::HousingBenefits < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "hb"
    @copy_key = "sales.income_benefits_and_savings.housing_benefits.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Housing benefit" },
    "3" => { "value" => "Universal Credit housing element" },
    "divider" => { "value" => true },
    "1" => { "value" => "Neither housing benefit or Universal Credit housing element" },
    "4" => { "value" => "Don’t know " },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 71, 2024 => 73 }.freeze
end
