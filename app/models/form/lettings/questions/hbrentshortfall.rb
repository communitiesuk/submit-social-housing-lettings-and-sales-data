class Form::Lettings::Questions::Hbrentshortfall < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hbrentshortfall"
    @check_answer_label = "Any outstanding amount for basic rent and charges"
    @header = "After the household has received any housing-related benefits, will they still need to pay for rent and charges?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "Also known as the ‘outstanding amount’."
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 99, 2024 => 98 }.freeze
end
