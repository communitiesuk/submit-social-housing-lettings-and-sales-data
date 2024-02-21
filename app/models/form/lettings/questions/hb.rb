class Form::Lettings::Questions::Hb < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hb"
    @check_answer_label = "Housing-related benefits received"
    @header = "Is the household likely to be receiving any of these housing-related benefits?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = form.start_year_after_2024? ? "This is about when the tenant is in their new let. If they are unsure about the situation for their new let and their financial and working situation hasn’t changed significantly, answer based on what housing-related benefits they currently receive." : ""
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Housing benefit" },
    "6" => { "value" => "Universal Credit housing element" },
    "9" => { "value" => "Neither" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
    "10" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 89, 2024 => 88 }.freeze
end
