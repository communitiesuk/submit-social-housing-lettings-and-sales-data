class Form::Lettings::Questions::Incfreq < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "incfreq"
    @check_answer_label = "How often does the household receive this amount?"
    @header = "How often does the household receive this amount?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = true
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Weekly" },
    "2" => { "value" => "Monthly" },
    "3" => { "value" => "Yearly" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 87, 2024 => 86 }.freeze
end
