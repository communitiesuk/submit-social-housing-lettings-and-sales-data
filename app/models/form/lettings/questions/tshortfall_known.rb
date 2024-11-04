class Form::Lettings::Questions::TshortfallKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tshortfall_known"
    @copy_key = "lettings.income_and_benefits.outstanding_amount.tshortfall_known"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "tshortfall" => [0] }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 100, 2024 => 99 }.freeze
end
