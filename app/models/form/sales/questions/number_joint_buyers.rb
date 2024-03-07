class Form::Sales::Questions::NumberJointBuyers < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "jointmore"
    @check_answer_label = "More than 2 joint buyers"
    @header = "Are there more than 2 joint buyers of this property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  def hint_text
    if form.start_year_after_2024?
      nil
    else
      "You should still try to answer all questions even if the buyers weren’t interviewed in person"
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 10, 2024 => 12 }.freeze
end
