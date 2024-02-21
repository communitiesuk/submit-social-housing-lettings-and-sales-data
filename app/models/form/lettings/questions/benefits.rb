class Form::Lettings::Questions::Benefits < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "benefits"
    @check_answer_label = "Household income from Universal Credit, state pension or benefits"
    @header = "How much of the household’s income is from Universal Credit, state pensions or benefits?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "This excludes child and housing benefit, council tax support and tax credits."
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "All" },
    "2" => { "value" => "Some" },
    "3" => { "value" => "None" },
    "divider" => { "value" => true },
    "4" => { "value" => "Don’t know" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 90, 2024 => 89 }.freeze
end
