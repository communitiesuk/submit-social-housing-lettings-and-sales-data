class Form::Lettings::Questions::IsCarehome < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "is_carehome"
    @copy_key = "lettings.income_and_benefits.care_home.is_carehome"
    @type = "radio"
    @check_answers_card_number = 0
    @conditional_for = { "chcharge" => [1] }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def answer_options
    if form.start_year_2024_or_later?
      {
        "1" => { "value" => "Yes" },
        "0" => { "value" => "No" },
      }.freeze
    else
      {
        "0" => { "value" => "No" },
        "1" => { "value" => "Yes" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 93, 2024 => 92 }.freeze
end
