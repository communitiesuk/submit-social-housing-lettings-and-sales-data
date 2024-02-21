class Form::Sales::Questions::Buyer2EthnicBackgroundWhite < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @check_answer_label = "Buyer 2’s ethnic background"
    @header = "Which of the following best describes buyer 2’s White background?"
    @type = "radio"
    @check_answers_card_number = 2
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  def answer_options
    if form.start_year_after_2024?
      {
        "1" => { "value" => "English, Welsh, Northern Irish, Scottish or British" },
        "2" => { "value" => "Irish" },
        "18" => { "value" => "Gypsy or Irish Traveller" },
        "20" => { "value" => "Roma" },
        "3" => { "value" => "Any other White background" },
      }.freeze
    else
      {
        "1" => { "value" => "English, Welsh, Northern Irish, Scottish or British" },
        "2" => { "value" => "Irish" },
        "18" => { "value" => "Gypsy or Irish Traveller" },
        "3" => { "value" => "Any other White background" },
      }.freeze
    end
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 31, 2024 => 33 }.freeze
end
