class Form::Lettings::Questions::TshortfallKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tshortfall_known"
    @check_answer_label = "Do you know the outstanding amount?"
    @header = "Can you estimate the outstanding amount?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "You only need to give an approximate figure."
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "tshortfall" => [0] }
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 100, 2024 => 99 }.freeze
end
