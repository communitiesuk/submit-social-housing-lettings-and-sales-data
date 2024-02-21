class Form::Sales::Questions::Prevshared < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevshared"
    @check_answer_label = "Previous property shared ownership?"
    @header = "Was the previous property under shared ownership?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "For any buyer"
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 74, 2024 => 76 }.freeze
end
