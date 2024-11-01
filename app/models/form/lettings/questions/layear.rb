class Form::Lettings::Questions::Layear < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "layear"
    @type = "radio"
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def answer_options
    if form.start_year_after_2024?
      {
        "1" => { "value" => "Just moved to local authority area with this new let" },
        "2" => { "value" => "Less than 1 year" },
        "7" => { "value" => "1 year but under 2 years" },
        "8" => { "value" => "2 years but under 3 years" },
        "9" => { "value" => "3 years but under 4 years" },
        "10" => { "value" => "4 years but under 5 years" },
        "11" => { "value" => "5 years but under 10 years" },
        "12" => { "value" => "10 years or more" },
        "divider" => { "value" => true },
        "6" => { "value" => "Don’t know" },
      }
    else
      {
        "1" => { "value" => "Just moved to local authority area" },
        "2" => { "value" => "Less than 1 year" },
        "7" => { "value" => "1 year but under 2 years" },
        "8" => { "value" => "2 years but under 3 years" },
        "9" => { "value" => "3 years but under 4 years" },
        "10" => { "value" => "4 years but under 5 years" },
        "5" => { "value" => "5 years or more" },
        "divider" => { "value" => true },
        "6" => { "value" => "Don’t know" },
      }
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 75, 2024 => 74 }.freeze
end
