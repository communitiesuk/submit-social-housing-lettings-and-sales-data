class Form::Lettings::Questions::Reasonpref < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reasonpref"
    @check_answer_label = "Household given reasonable preference"
    @header = "Was the household given ‘reasonable preference’ by the local authority?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = form.start_year_after_2024? ? "Households may be given ‘reasonable preference’ for social housing under one or more specific categories by the local authority. This is also known as ‘priority need’." : "Households may be given ‘reasonable preference’ for social housing, also known as ‘priority need’, by the local authority."
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 82, 2024 => 81 }.freeze
end
