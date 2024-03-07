class Form::Sales::Questions::Prevshared < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevshared"
    @check_answer_label = "Previous property shared ownership?"
    @header = "Was the previous property under shared ownership?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "For any buyer"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 74, 2024 => 76 }.freeze
end
