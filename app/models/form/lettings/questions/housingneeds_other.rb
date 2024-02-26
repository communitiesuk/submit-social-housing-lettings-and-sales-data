class Form::Lettings::Questions::HousingneedsOther < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "housingneeds_other"
    @check_answer_label = "Other disabled access needs"
    @header = "Do they have any other disabled access needs?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def answer_options
    if form.start_year_after_2024?
      {
        "1" => { "value" => "Yes" },
        "0" => { "value" => "No" },
        "2" => { "value" => "Don't know" },
      }.freeze
    else
      {
        "1" => { "value" => "Yes" },
        "0" => { "value" => "No" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 72, 2024 => 71 }.freeze
end
