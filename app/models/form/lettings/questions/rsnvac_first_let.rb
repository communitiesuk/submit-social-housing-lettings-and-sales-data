class Form::Lettings::Questions::RsnvacFirstLet < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "rsnvac"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "16" => { "value" => "First let of conversion, rehabilitation or acquired property" },
    "17" => { "value" => "First let of leased property" },
    "15" => { "value" => "First let of new-build property" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 15, 2024 => 16 }.freeze
end
