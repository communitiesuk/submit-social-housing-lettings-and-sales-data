class Form::Sales::Questions::Buyer1EthnicBackgroundWhite < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @check_answer_label = "Buyer 1’s ethnic background"
    @header = "Which of the following best describes buyer 1’s White background?"
    @type = "radio"
    @hint_text = form.start_year_after_2024? ? "" : "Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @check_answers_card_number = 1
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
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

  QUESION_NUMBER_FROM_YEAR = { 2023 => 23, 2024 => 25 }.freeze
end
