class Form::Lettings::Questions::IsCarehome < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "is_carehome"
    @check_answer_label = "Care home accommodation"
    @header = "Is this accommodation a care home?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @conditional_for = { "chcharge" => [1] }
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  def answer_options
    if form.start_year_after_2024?
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

  QUESION_NUMBER_FROM_YEAR = { 2023 => 93, 2024 => 92 }.freeze
end
