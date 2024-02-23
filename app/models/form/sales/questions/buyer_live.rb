class Form::Sales::Questions::BuyerLive < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buylivein"
    @check_answer_label = "Buyers living in property"
    @header = form.start_year_after_2024? ? "Will any buyers live in the property?" : "Will the buyers live in the property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 8, 2024 => 10 }.freeze
end
