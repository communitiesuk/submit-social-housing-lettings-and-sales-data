class Form::Lettings::Questions::Armedforces < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "armedforces"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes – the person is a current or former regular" },
    "4" => { "value" => "Yes – the person is a current or former reserve" },
    "5" => { "value" => "Yes – the person is a spouse or civil partner of a UK armed forces member and has been bereaved or separated from them within the last 2 years" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Person prefers not to say" },
    "divider" => { "value" => true },
    "6" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 66, 2024 => 65 }.freeze
end
